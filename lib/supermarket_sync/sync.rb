# Encoding: UTF-8
#
# Gem Name:: supermarket_sync
# Module:: Sync
#
# The MIT License (MIT)
#
# Copyright:: 2021, Brian Dwyer - Broadridge Financial Solutions
#

require 'chef/http/json_input'
require 'chef/http/json_output'
require 'chef/http/remote_request_id'
require 'chef/http/simple_json'
require 'chef/knife/core/cookbook_site_streaming_uploader'
require 'mixlib/cli'
require 'supermarket_sync/notifier'

module SupermarketSync
  #
  # => Supermarket Synchronization Logic Controller
  #
  module Sync
    module_function

    def run! # rubocop: disable AbcSize, CyclomaticComplexity, MethodLength, PerceivedComplexity
      Config.supermarkets.each do |name, cfg| # rubocop: disable BlockLength
        puts "Synchronizing #{name}"

        # => Set Configuration
        configure(cfg)

        # => Parse the Cookbooks List
        cookbooks = Array(Util.parse_json(Config.cookbooks_file)[:cookbooks])

        cookbooks.each do |cookbook| # rubocop: disable BlockLength
          cookbook = cookbook.keys.first if cookbook.is_a?(Hash)
          puts "Checking #{cookbook}"
          # => Grab Source Metadata
          source_meta = begin
                          src.get("/api/v1/cookbooks/#{cookbook}")
                        rescue Net::HTTPServerException => e
                          raise e unless e.response.code == '404'
                          puts 'Cookbook not available on Source Supermarket'
                          next
                        end
          # => Grab Latest Available Version Number
          latest = ::Gem::Version.new(::File.basename(source_meta['latest_version']))

          # => Grab Destination Metadata
          dest_meta = begin
                        dest.get("/api/v1/cookbooks/#{cookbook}")
                      rescue Net::HTTPServerException => e
                        raise e unless e.response.code == '404'
                        # => Cookbook not found -- Initial Upload
                        { 'latest_version' => '0.0.0' }
                      end
          # => Determine Current Version
          current = ::Gem::Version.new(::File.basename(dest_meta['latest_version']))

          if latest > current
            puts 'Updating...'
            puts "Source: #{latest}"
            puts "Destination: #{current}"

            # => Retrieve the Cookbook
            tgz = src.streaming_request("/api/v1/cookbooks/#{cookbook}/versions/#{latest}/download")

            # => Upload the Cookbook
            upload('other', tgz) unless Config.read_only

            # => Remove the Tempfile
            begin
              retries ||= 2
              ::File.delete(tgz)
            rescue => e # rubocop: disable RescueStandardError
              raise e if (retries -= 1).negative?
              puts "#{e.class}::#{e.message}"
              puts 'Could not delete Tempfile... Retrying'
              sleep 2
              retry
            end
            @notify&.updated&.push(source: source_meta, dest: dest_meta)
          end
          # => Identify Deprecated Cookbooks
          next unless source_meta['deprecated'] && !dest_meta['deprecated']
          @notify&.deprecated&.push(source: source_meta, dest: dest_meta)
        end
      ensure
        # => Send Notifications
        @notify&.send!
      end
    end

    #
    # => Configuration Context
    #

    private def configure(context) # rubocop: disable AbcSize, MethodLength
      Chef::Config.tap do |cfg|
        cfg.chef_server_url = context[:url]
        cfg.node_name       = context[:user] || ENV['SM_USER']
        cfg.client_key      = context[:key]  || ENV['SM_KEY']
        cfg.ssl_verify_mode = :verify_none
      end

      if Config.notification.any?
        @notify = Notifier.new do |cfg|
          cfg.url      = Config.notification[:url]
          cfg.channels = Config.notification[:channels]
          cfg.username = Config.notification[:username]
        end
      end

      src  context[:source] || Config.source
      dest context[:url]
    end

    #
    # => API Clients
    #
    def src(url = nil)
      url ||= @src&.url
      raise ArgumentError, 'No URL supplied!' unless url
      return @src if @src&.url == url
      @src = Chef::HTTP::SimpleJSON.new(url)
    end

    private def dest(url = nil)
      url ||= @dest&.url
      raise ArgumentError, 'No URL supplied!' unless url
      return @dest if @dest&.url == url
      @dest = Chef::HTTP::SimpleJSON.new(url)
    end

    private def upload(category, tarball) # rubocop: disable AbcSize, MethodLength
      uri = URI.parse(dest.url)
      uri.path = '/api/v1/cookbooks'
      resp = Chef::CookbookSiteStreamingUploader.post(
        uri.to_s, Chef::Config[:node_name], Chef::Config[:client_key],
        tarball: ::File.open(tarball),
        cookbook: Chef::JSONCompat.to_json(category: category)
      )
      return if %w[200 201].include?(resp.code)
      msg = Chef::JSONCompat.to_json_pretty(Chef::JSONCompat.parse(resp.body)) rescue resp.body # rubocop: disable RescueModifier, LineLength
      puts resp.inspect
      raise "\nSupermarket Upload Error:\n#{msg}"
    end
  end
end
