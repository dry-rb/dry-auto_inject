# Dry::AutoInject <a href="https://gitter.im/dryrb/chat" target="_blank">![Join the chat at https://gitter.im/dryrb/chat](https://badges.gitter.im/Join%20Chat.svg)</a>

<a href="https://rubygems.org/gems/dry-auto_inject" target="_blank">![Gem Version](https://badge.fury.io/rb/dry-auto_inject.svg)</a>
<a href="https://travis-ci.org/dryrb/dry-auto_inject" target="_blank">![Build Status](https://travis-ci.org/dryrb/dry-auto_inject.svg?branch=master)</a>
<a href="https://gemnasium.com/dryrb/dry-auto_inject" target="_blank">![Dependency Status](https://gemnasium.com/dryrb/dry-auto_inject.svg)</a>
<a href="https://codeclimate.com/github/dryrb/dry-auto_inject" target="_blank">![Code Climate](https://codeclimate.com/github/dryrb/dry-auto_inject/badges/gpa.svg)</a>
<a href="http://inch-ci.org/github/dryrb/dry-auto_inject" target="_blank">![Documentation Status](http://inch-ci.org/github/dryrb/dry-auto_inject.svg?branch=master&style=flat)</a>

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

## Usage

You can use `AutoInject` with any container that responds to `[]`. In this example
we're going to use `dry-container`:

```ruby
# set up your container
my_container = Dry::Container.new

my_container.register(:data_store, -> { DataStore.new })
my_container.register(:user_repository, -> { container[:data_store][:users] })
my_container.register(:persist_user, -> { PersistUser.new })

# set up your auto-injection module

AutoInject = Dry::AutoInject.new { container(my_container) }

# then simply include it in your class providing which dependencies should be
# injected automatically from the configure container
class PersistUser
  include AutoInject[:user_repository]

  def call(user)
    user_repository << user
  end
end

persist_user = my_container[:persist_user]

persist_user.call(name: 'Jane')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dryrb/dry-auto_inject.

