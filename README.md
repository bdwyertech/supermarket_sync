# SupermarketSync
* Ruby Gem to programmatically synchronize Chef Supermarkets

## Background
This gem was built from a need to synchronize approved cookbooks to a private, internal Chef Supermarket from the Public Chef Supermarket.

It was also desired to send notifications upon changes and deprecations.

## Usage

```shell
Usage: supermarket_sync (options)
    -c, --config CONFIG              Path to the configuration file to use
        --cookbooks-json CONFIG      List of cookbooks to synchronize
```

* Supermarkets can be configured individually via the configuration file.

* If left unspecified, global Supermarket parameters can be passed in via environment variables.

```
# Set Supermarket Globals
export SM_USER='supermarket_user'
export SM_KEY='/path/to/my/key.pem'

# Sync the Supermarkets
supermarket_sync -c config.json --cookbooks-json cookbooks.json
```

* Slack notifications are optional and can be configured via notification hash in `config.json`.

#### Configuration Samples

`config.json`
```json
{
  "notification": {
    "url": "https://hooks.slack.com/services/T23CHARKH/blah/blahbetyblah",
    "username": "Chef - Supermarket Sync",
    "channels": [
      "@bdwyertech",
      "#chef-pipeline"
    ]
  },
  "supermarkets": {
    "Enterprise BU1": {
      "url": "https://supermarket.bu1.contoso.net"
    },
    "Enterprise BU2": {
      "url": "https://supermarket.bu2.contoso.net",
      "user": "bu2_admin",
      "key": "/path/to/bu2/admin/key.pem"
    }
  }
}
```

`cookbooks.json`
```json
{
  "cookbooks": [
    "apt",
    "java",
    "mysql",
    "yum"
  ]
}
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'supermarket_sync'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install supermarket_sync


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bdwyertech/supermarket_sync. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
