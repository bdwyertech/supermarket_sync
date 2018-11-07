# Encoding: UTF-8
#
# Gem Name:: supermarket_sync
# Module:: Util
#
# Copyright (C) 2018 Brian Dwyer - Intelligent Digital Services
#
# All rights reserved - Do Not Redistribute
#

require 'json'

module SupermarketSync
  # => Utility Methods
  module Util
    module_function

    ########################
    # =>    File I/O    <= #
    ########################

    # => Define JSON Parser
    def parse_json(file = nil, symbolize = true)
      return unless file && ::File.exist?(file.to_s)
      begin
        ::JSON.parse(::File.read(file.to_s), symbolize_names: symbolize)
      rescue JSON::ParserError => e
        puts "#{e.class}:: #{file}"
        return
      end
    end

    # => Define JSON Writer
    def write_json(file, object)
      return unless file && object
      begin
        File.open(file, 'w') { |f| f.write(JSON.pretty_generate(object)) }
      end
    end
  end
end
