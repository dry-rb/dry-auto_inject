---
title: Basic usage
layout: gem-single
name: dry-auto_inject
---

### Requirements

You need only one thing before you can use dry-auto\_inject: a container to hold your application’s dependencies. These are commonly known as “inversion of control” containers.

A [dry-container](/gems/dry-container) will work well, but the only requirement is that the container responds to the `#[]` interface. For example, `my_container["users_repository"]` should return the “users_repository” object registered with the container.

### Creating an injector

To create an injector, pass the container to `Dry::AutoInject`:

```ruby
Import = Dry::AutoInject(my_container)
```

Assign the injector to a constant (or make it globally accessible somehow) so you can refer to it from within your classes.

### Specifying dependencies

To specify the dependencies for a class, mix in the injector and provide the container identifiers for each dependency:

```ruby
class MyClass
  include Import["users_repository", "deliver_welcome_email"]
end
```

### Using dependencies

Each dependency is available via a reader with a matching name:

```ruby
class MyClass
  include Import["users_repository"]

  def call
    puts users_repository.inspect
  end
end
```

If your container identifiers include delimiters (like `"."`) or other characters that are not allowed within variable or method names, then the final part of the name will be used instead:

```ruby
class MyClass
  include Import["repositories.users"]

  def call
    puts users.inspect
  end
end
```

### Specifying aliases for dependencies

You can specify dependencies as a hash to provide your own names for each one:

```ruby
class MyClass
  include Import[users_repo: "repositories.users"]

  def call
    puts users_repo.inspect
  end
end
```

If you want to provide a mix of inferred names and aliases, provide the aliases last:

```ruby
class MyClass
  include Import[
    "repositories.users",
    deliver_email: "operations.deliver_welcome_email",
  ]
end
```

### Initializing your object

Initialize your object without any arguments and all the dependencies will be resolved from the the container automatically:

```ruby
my_obj = MyClass.new
```

### Passing manual dependencies

To provide an alternative object for a dependency, pass it to the initializer with a keyword argument matching the dependency’s name:

```ruby
class MyClass
  include Import["repositories.users"]
end

my_obj = MyClass.new(users: different_repo)
```

This technique is useful when testing your class in isolation. You can pass in test doubles to verify your class’ behaviour under various different circumstances.
