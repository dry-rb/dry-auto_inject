[gem]: https://rubygems.org/gems/dry-auto_inject
[ci]: https://github.com/dry-rb/dry-auto_inject/actions?query=workflow%3Aci
[codeclimate]: https://codeclimate.com/github/dry-rb/dry-auto_inject
[coveralls]: https://coveralls.io/r/dry-rb/dry-auto_inject
[inchpages]: http://inch-ci.org/github/dry-rb/dry-auto_inject
[chat]: https://dry-rb.zulipchat.com

# dry-auto_inject [![Join the chat at https://dry-rb.zulipchat.com](https://img.shields.io/badge/dry--rb-join%20chat-%23346b7a.svg)][chat]

[![Gem Version](https://badge.fury.io/rb/dry-auto_inject.svg)][gem]
[![Build Status](https://github.com/dry-rb/dry-auto_inject/workflows/ci/badge.svg)][ci]
[![Code Climate](https://codeclimate.com/github/dry-rb/dry-auto_inject/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/dry-rb/dry-auto_inject/badges/coverage.svg)][codeclimate]
[![Inline docs](http://inch-ci.org/github/dry-rb/dry-auto_inject.svg?branch=master)][inchpages]
![No monkey-patches](https://img.shields.io/badge/monkey--patches-0-brightgreen.svg)

A simple extension which allows you to automatically inject dependencies to your
object constructors from a configured container.

It does 3 things:

- Defines a constructor which accepts dependencies
- Defines attribute readers for dependencies
- Injects dependencies automatically to the constructor with overridden `.new`

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dry-auto_inject'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install dry-auto_inject
```

## Links

- [Documentation](http://dry-rb.org/gems/dry-auto_inject/)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dry-rb/dry-auto_inject.
