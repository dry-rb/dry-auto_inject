# v.0.3.0, 2016-06-02

### Added

* Support for new `kwargs` and `hash` injection strategies

    These strategies can be accessed via methods on the main builder object:

    ```ruby
    MyInject = Dry::AutoInject(my_container)

    class MyClass
      include MyInject.hash["my_dep"]
    end
    ```
* Support for user-provided injection strategies

    All injection strategies are now held in their own `Dry::AutoInject::Strategies` container. You can add register your own strategies to this container, or choose to provide a strategies container of your own:

    ```ruby
    class CustomStrategy < Module
      # Your strategy code goes here :)
    end

    # Registering your own strategy (globally)
    Dry::AutoInject::Strategies.register :custom, CustomStrategy

    MyInject = Dry::AutoInject(my_container)

    class MyClass
      include MyInject.custom["my_dep"]
    end

    # Providing your own container (keeping the existing strategies in place)
    class MyStrategies < Dry::AutoInject::Strategies
      register :custom, CustomStrategy
    end

    MyInject = Dry::AutoInject(my_container, strategies: MyStrategies)

    class MyClass
      include MyInject.custom["my_dep"]
    end

    # Proiding a completely separated container
    class MyStrategies
      extend Dry::Container::Mixin
      register :custom, CustomStrategy
    end

    MyInject = Dry::AutoInject(my_container, strategies: MyStrategies)

    class MyClass
      include MyInject.custom["my_dep"]
    end
    ```
* User-specified aliases for dependencies

    These aliases enable you to specify your own name for dependencies, both for their local readers and their keys in the kwargs- and hash-based initializers. Specify aliases by passing a hash of names:

    ```ruby
    MyInject = Dry::AutoInject(my_container)

    class MyClass
      include MyInject[my_dep: "some_other.dep"]

      # Refer to the dependency as `my_dep` inside the class
    end

    # Pass your own replacements using the `my_dep` initializer key
    my_obj = MyClass.new(my_dep: something_else)
    ```

    A mix of both regular and aliased dependencies can also be injected:

    ```ruby
    include MyInject["some_dep", another_dep: "some_other.dep"]
    ```

* Inspect the `super` method of the including class’s `#initialize` and send it arguments that will match its own arguments list/arity. This allows auto_inject to be used more easily in existing class inheritance heirarchies.

### Changed

* `kwargs` is the new default injection strategy
* Rubinius support is not available for the `kwargs` strategy (see [#18](https://github.com/dry-rb/dry-auto_inject/issues/18))

# v0.2.0 2016-02-09

### Added

* Support for hashes as constructor arguments via `Import.hash` interface (solnic)

[Compare v0.1.0...v0.2.0](https://github.com/dryrb/dry-auto_inject/compare/v0.1.0...v0.2.0)

# v0.1.0 2015-11-12

Changed interface from `Dry::AutoInject.new { container(some_container) }` to
`Dry::AutoInject(some_container)`.

# v0.0.1 2015-08-20

First public release \o/
