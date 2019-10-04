---
title: How does it work?
layout: gem-single
name: dry-auto_inject
---

dry-auto\_inject enables _constructor dependency injection_ for your objects. It achieves this by defining two methods in the module that you include in your class.

First, it defines `.new`, which resolves your dependencies from the container, if you haven't otherwise provided them as explicit arguments. It then passes these dependencies as arguments onto `#initialize`, as per Ruby’s usual behaviour.

It also defines `#initialize`, which receives these dependencies as arguments and then assigns them to instance variables. These variables are made available via `attr_reader`s.

So when you specify dependencies like this:

```ruby
Import = Dry::AutoInject(MyContainer)

class MyClass
  include Import["users_repository"]
end
```

You’re building something like this (this isn’t a line-for-line copy of what is mixed into your class; it’s intended as a guide only):

```ruby
class MyClass
  attr_reader :users_repository

  def self.new(**args)
    deps = {
      users_repository: args[:users_repository] || MyContainer["users_repository"]
    }

    super(**deps)
  end

  def initialize(users_repository: nil)
    super()

    @users_repository = users_repository
  end
end
```

Since these methods are defined in the module that you include in your class, you can still override them in your class if you wish to provide custom behavior.
