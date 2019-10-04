---
title: Injection strategies
layout: gem-single
name: dry-auto_inject
---

dry-auto\_inject supports three _injection strategies_, allowing you to design and integrate with different kinds of classes.

These strategies all provide _constructor dependency injection_: dependencies are passed when creating your objects. The strategies differ in how they expect dependencies to be passed to the initializer.

## Choosing a strategy

Choose a strategy when you build the injector:

```ruby
# Default keyword arguments strategy
Import = Dry::AutoInject(MyContainer)

# Positional arguments strategy
Import = Dry::AutoInject(MyContainer).args
```

Strategies can also be chained from existing injectors, which means you can set up a single injector for your most commonly used strategy, then use a different strategy directly in particular classes if they have differing requirements. For example:

```ruby
# Set up a standard strategy for your app
Import = Dry::AutoInject(MyContainer)

class MyClass
 # Use the standard strategy here
 include Import["users_repository"]
end

class SpecialClass
 # Use a different strategy in this particular class
 include Import.args["users_repository"]
end
```

## Strategies

### Keyword arguments (`kwargs`)

This is the default strategy.

Pass dependencies to the initializer using keyword arguments.

```ruby
Import = Dry::AutoInject(MyContainer)

class MyClass
 include Import["users_repository"]
end

MyClass.new(users_repository: my_repo)
```

The `#initialize` method has two possible argument signatures:

- If there is no `super` method for `#initialize`, or the `super` method takes no arguments, then the keyword arguments will be explicit, e.g. `#initialize(users_repository: nil)`.
- If the `super` method for `#initialize` takes its own set of keyword arguments, then the arguments will be a single splat, e.g. `#initialize(**args)`.

### Options hash (`hash`)

Pass the dependencies to the initializer as a single hash.

```ruby
Import = Dry::AutoInject(MyContainer).hash

class MyClass
 include Import["users_repository"]
end

# This can also take `{users_repo: my_repo}`
MyClass.new(users_repository: my_repo)
```

The `#initialize` method has an argument signature of `#initialize(options)`, where `options` is expected to be a hash.

### Positional arguments (`args`)

Pass dependencies to the initializer using standard positional arguments.

```ruby
Import = Dry::AutoInject(MyContainer).args

class MyClass
 include Import["users_repository"]
end

MyClass.new(my_repo)
```

The `#initialize` method has an argument signature with a named positional argument for each dependency, e.g. `#initialize(users_repository)`.
