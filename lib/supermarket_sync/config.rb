# Encoding: UTF-8
#
# Gem Name:: supermarket_sync
# Module:: Config
#
# The MIT License (MIT)
#
# Copyright:: 2018, Brian Dwyer - Broadridge Financial Solutions
#

require 'supermarket_sync/helpers/configuration'
require 'pathname'

module SupermarketSync
  # => This is the Configuration module.
  module Config
    module_function

    extend Configuration

    # => Gem Root Directory
    define_setting :root, Pathname.new(File.expand_path('../..', __dir__))

    # => My Name
    define_setting :author, 'Brian Dwyer - Broadridge Financial Services'

    # => Config File
    define_setting :config_file, File.join(root, 'config', 'config.json')

    # => Cookbooks File
    define_setting :cookbooks_file, File.join(root, 'config', 'cookbooks.json')

    # => Supermarket Configuration
    define_setting :supermarkets, {}

    # => Global Notification
    define_setting :notification, {}

    # => Global Supermarket Source
    define_setting :source, 'https://supermarket.chef.io'

    # => Global Chef Defaults
    define_setting :defaults, url:  ENV['SM_URL'],
                              user: ENV['SM_USER'],
                              key:  ENV['SM_KEY']

    #
    # Facilitate Dynamic Addition of Configuration Values
    #
    # @return [class_variable]
    #
    def add(config = {})
      config.each do |key, value|
        define_setting key.to_sym, value
      end
    end

    #
    # Facilitate Dynamic Removal of Configuration Values
    #
    # @return nil
    #
    def clear(config)
      Array(config).each do |setting|
        delete_setting setting
      end
    end

    #
    # List the Configurable Keys as a Hash
    #
    # @return [Hash]
    #
    def options
      map = SupermarketSync::Config.class_variables.map do |key|
        [key.to_s.tr('@', '').to_sym, class_variable_get(:"#{key}")]
      end
      Hash[map]
    end
  end
end
