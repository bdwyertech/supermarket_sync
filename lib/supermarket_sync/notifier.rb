# Encoding: UTF-8
#
# Gem Name:: supermarket_sync
# Module:: Notifier
#
# The MIT License (MIT)
#
# Copyright:: 2018, Brian Dwyer - Broadridge Financial Solutions
#

require 'slack-notifier'

module SupermarketSync
  #
  # => Notifications
  #
  class Notifier
    attr_accessor :url, :username, :channels

    def initialize(**args)
      @url       = args[:url]
      @channels  = args[:channels]
      @username  = args[:username]
      @http_opts = args[:http_opts] || {}
      yield self if block_given?
    end

    def send!
      messages = [build_deprecated, build_updated].compact
      return unless messages.any?
      Array(@channels).each do |channel|
        slack.ping '', attachments: messages, channel: channel
      end
    end

    def slack
      (cfg = {})[:username] = @username
      cfg[:http_options] = { verify_mode: OpenSSL::SSL::VERIFY_NONE }

      Slack::Notifier.new @url do
        defaults cfg
      end
    end

    #
    # => Accumulators
    #

    def deprecated
      @deprecated ||= []
    end

    def updated
      @updated ||= []
    end

    #
    # => Message Constructors
    #

    private def build_deprecated # rubocop: disable MethodLength
      return unless deprecated.any?
      fields = deprecated.map do |cb|
        {
          title: cb[:source]['name'],
          short: true,
          value: <<-MSGBODY.gsub(/^\s+/, '')
            * Replacement: #{cb[:source]['replacement'] || '**NONE**'}
          MSGBODY
        }
      end

      {
        color:  '#FF0000',
        mrkdwn_in: %w[pretext fields],
        fields: fields,
        pretext: <<-MSGBODY.gsub(/^\s+/, '')
          <!here> :warning: **The following cookbooks have been deprecated:**
        MSGBODY
      }
    end

    private def build_updated # rubocop: disable AbcSize, MethodLength
      return unless updated.any?
      rows = updated.map do |cb|
        [
          '|',
          "[#{cb[:source]['name']}](#{cb[:source]['external_url']})",
          '|',
          ::File.basename(cb[:source]['latest_version']),
          '|',
          cb[:source]['deprecated'] ? ':warning:' : ':white_check_mark:',
          '|'
        ].join(' ')
      end.join("\n")

      {
        mrkdwn_in: %w[text],
        pretext: '<!here> :checkered_flag: **The following cookbooks have been synchronized:**',
        short: false,
        text: <<-MSGBODY.gsub(/^\s+/, '')
        | Cookbook | Version | Deprecation Status |
        |:--------:|:-------:|:------------------:|
        #{rows}
        MSGBODY
      }
    end
  end
end
