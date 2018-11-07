# Encoding: UTF-8
#
# Chef - Supermarket Sync
# Brian Dwyer - Intelligent Digital Services - 11/7/18

require 'supermarket_sync/cli'
require 'supermarket_sync/config'
require 'supermarket_sync/util'
require 'supermarket_sync/version'

# => Chef Supermarket Synchronization Utility
module SupermarketSync
  autoload :Sync, 'supermarket_sync/sync'
end
