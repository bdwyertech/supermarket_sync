# Encoding: UTF-8
#
# Gem Name:: supermarket_sync
# Module:: CLI
#
# The MIT License (MIT)
#
# Copyright:: 2021, Brian Dwyer - Broadridge Financial Solutions
#

require 'mixlib/cli'
require 'supermarket_sync/config'
require 'supermarket_sync/util'

module SupermarketSync
  #
  # => SupermarketSync Launcher
  #
  module CLI
    module_function

    #
    # => Options Parser
    #
    class Options
      # => Mix-In the CLI Option Parser
      include Mixlib::CLI
      option :config_file,
             short: '-c CONFIG',
             long: '--config CONFIG',
             description: 'Path to the configuration file to use'

      option :cookbooks_file,
             long: '--cookbooks-json CONFIG',
             description: 'List of cookbooks to synchronize'
    end

    #
    # => Launch the Application
    #
    def run(argv = ARGV) # rubocop: disable AbcSize, MethodLength
      #
      # => Parse CLI Configuration
      #
      cli = Options.new
      cli.parse_options(argv)

      # => Grab the Default Values
      default = Config.options

      # => Parse JSON Config File (If Specified and Exists)
      json_config = Util.parse_json(cli.config[:config_file] || Config.config_file)

      # => Merge Configuration (CLI Wins)
      config = [default, json_config, cli.config].compact.reduce(:merge)

      # => Apply Configuration
      Config.setup do |cfg|
        cfg.cookbooks_file = config[:cookbooks_file]
        cfg.notification   = config[:notification]
        cfg.supermarkets   = config[:supermarkets]
        cfg.source         = config[:source]
        cfg.read_only      = config[:read_only]
      end

      # => Start the Sync
      Sync.run!
    end
  end
end
