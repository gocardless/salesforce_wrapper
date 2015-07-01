# Salesforce Wrapper

[![Build Status](https://travis-ci.org/gocardless/salesforce_wrapper.svg)](https://travis-ci.org/gocardless/salesforce_wrapper)

A wrapper for [Restforce](https://github.com/ejholmes/restforce) which provides customised handling of exceptions and simple global configuration.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'salesforce_wrapper', github: 'gocardless/salesforce_wrapper'
```

And then execute:

    $ bundle

## Usage

Simply call methods on `Salesforce` in the same way as you would on a Restforce client instance.

```ruby
Salesforce.find("Opportunity", "an ID goes here")
```

First, you'll need to set `Salesforce` with `config` (which will be used to instantiate a Restforce client) and an `exception_handler`, a lambda which will be called when a `Faraday::ClientError` occurs (for example when a validation error occurs on creating or saving a Salesforce record). Other kinds of exceptions will be raised as normal.

Add the following to `config/initializers/salesforce.rb`:

```ruby
require 'yaml'
Salesforce.config = YAML.load_file("/path/to/restforce.yml")

Salesforce.exception_handler = lambda do |method, exception, arguments|
  AdminMailer.salesforce_error(method.to_s, exception.message, arguments).deliver
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gocardless/salesforce_wrapper. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

