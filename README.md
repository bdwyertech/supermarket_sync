# SupermarketSync
* Ruby Gem to programmatically synchronize Chef Supermarkets

## Background
This gem was built from a need to synchronize a private, internal Chef Supermarket from the Public Chef Supermarket.

At the same time, being able to send notifications of changes and deprecations was also desired.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'supermarket_sync'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install supermarket_sync

## Usage

#### Configuration Samples

```json
# Config.json
{
  "notify": {
    "url": "https://hooks.slack.com/services/T23CHARKH/blah/blahbetyblah",
    "username": "Chef - Supermarket Sync",
    "channels": [
      "@bdwyertech",
      "#chef-pipeline"
    ]
  },
  "supermarkets": {
    "Enterprise BU1": {
      "url": "https://supermarket.bu1.contoso.net",
      "user": "bu_admin",
      "key": "/path/to/bu1_admin_key.pem"
    },
    "Enterprise BU2": {
      "url": "https://supermarket.bu2.contoso.net",
      "user": "bu2_admin",
      "key": "/path/to/bu2_admin_key.pem"
    }
  }
}
```

```json
# cookbooks.json
{
  "cookbooks": [
    "apt",
    "java",
    "mysql",
    "yum"
  ]
}
```

####


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bdwyertech/supermarket_sync. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
