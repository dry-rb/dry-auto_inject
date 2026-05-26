# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Break Versioning](https://www.taoensso.com/break-versioning).

## [1.2.1] - 2026-05-26

### Fixed

- Load cop classes when the RuboCop plugin is required, so offenses are
  actually reported (@flash-gordon in #100)

[1.2.1]: https://github.com/dry-rb/dry-auto_inject/compare/v1.2.0...v1.2.1

## [1.2.0] - 2026-05-19

### Added

- Ship a `DryAutoInject/DependencyOrder` rubocop cop that enforces a configurable
  order for dependencies inside `Import[...]` calls. Non-aliased deps are
  emitted first, then aliased ones; within each section, deps are grouped by
  the configured `Order` patterns and sorted alphabetically inside a group.
  Supported pattern forms: `'*'` (catch-all, at most one and implicitly
  appended), `'prefix.*'`, `/regex/flags`, or an exact path. The cop also
  autocorrects. (@flash-gordon in #96)

  Enable it from your `.rubocop.yml` using RuboCop's plugin system
  (requires RuboCop 1.72+):

  ```yaml
  plugins:
    - dry-auto_inject

  DryAutoInject/DependencyOrder:
    Enabled: true
    InjectorModules:  # Default is [Import, *::Import, Deps, *::Deps]
      - Deps          # exact constant
      - "*::Deps"     # match any namespace ending in `::Deps`
    Order:
      - "web.*"
      - "*"
      - "core.*"
  ```

- Ship a `DryAutoInject/RedundantAlias` rubocop cop that flags
  `Import[foo: 'some.path.foo']`-style imports where the alias matches the
  last segment of the path, since dry-auto_inject already derives the
  dependency key from that segment. The cop autocorrects by promoting
  redundant aliases to non-aliased deps, preserving the original quoting.
  (@flash-gordon in #98)

### Fixed

- Ancestor parameter detection for smart kwarg forwarding is no longer obscured by injections in a parent class. (@alassek in #97)

### Changed

- Update minimum Ruby version to 3.3. (@timriley)

[1.2.0]: https://github.com/dry-rb/dry-auto_inject/compare/v1.1.0...v1.2.0

## [1.1.0] - 2025-01-07

### Fixed

- Update minimal ruby version to 3.1. (@flash-gordon)

[1.1.0]: https://github.com/dry-rb/dry-auto_inject/compare/v1.0.1...v1.1.0

## [1.0.1] - 2023-02-13

### Fixed

- Update passthrough parameters list to support ruby 3.2.1. (@hieuk09 in #88)

[1.0.1]: https://github.com/dry-rb/dry-auto_inject/compare/v1.0.0...v1.0.1

## [1.0.0] - 2022-11-18

### Changed

- This version is compatible with recently released dry-rb dependencies. (@flash-gordon)
- This version uses zeitwerk for autoloading. (@flash-gordon)

[1.0.0]: https://github.com/dry-rb/dry-auto_inject/compare/v0.9.0...v1.0.0

## [0.9.0] - 2022-01-26

### Changed

- [BREAKING] Support for ... was changed, now constructors with such signature are not considered
  as pass-through because they can forward arguments to another method. (@flash-gordon in #78)
- [BREAKING] Support for 2.6 was dropped

[0.9.0]: https://github.com/dry-rb/dry-auto_inject/compare/v0.8.0...v0.9.0

## [0.8.0] - 2021-06-06

### Added

- Support For `...` passthrough-args. (@ytaben)

### Fixed

- Constructors with kwargs strategy properly forward blocks to super. (@mintyfresh in #68)

### Changed

- [BREAKING] Support for 2.4 and 2.5 was dropped

[0.8.0]: https://github.com/dry-rb/dry-auto_inject/compare/v0.7.0...v0.8.0

## [0.7.0] - 2019-12-28

### Fixed

- Keyword warnings issued by Ruby 2.7 in certain contexts. (@flash-gordon)

### Changed

- [BREAKING] Support for 2.3 was dropped

[0.7.0]: https://github.com/dry-rb/dry-auto_inject/compare/v0.6.1...v0.7.0

## [0.6.1] - 2019-04-16

### Fixed

- Allow explicit injection of falsey values. (@timriley in #58)

[0.6.1]: https://github.com/dry-rb/dry-auto_inject/compare/v0.6.0...v0.6.1

## [0.6.0] - 2018-11-29

### Added

- Enhanced support for integrating with existing constructors. The kwargs strategy will now pass dependencies up to the next constructor if it accepts an arbitrary number of arguments with `*args`. Note that this change may break existing code though we think it's unlikely to happen. If something doesn't work for you please report and we'll try to sort it out. (@flash-gordon + @timriley in #48)

### Fixed

- A couple of regressions were fixed along the way, see [#46](https://github.com/dry-rb/dry-auto_inject/issues/46) and [#49](https://github.com/dry-rb/dry-auto_inject/issues/49). (@flash-gordon + @timriley in #48)

### Changed

- [BREAKING] 0.6.0 supports Ruby 2.3 and above. If you're on 2.3 keep in mind its EOL is scheduled at the end of March, 2019

[0.6.0]: https://github.com/dry-rb/dry-auto_inject/compare/v0.5.0...v0.6.0

## [0.5.0] - 2018-11-09

### Changed

- Only assign `nil` dependency instance variables from generated `#initialize` if the instance variable has not been previously defined. This improves compatibility with objects initialized in non-conventional ways (see example below). (@timriley in #47)

  ```ruby
  module SomeFramework
    class Action
      def self.new(configuration:, **args)
        # Do some trickery so `#initialize` on subclasses don't need to worry
        # about handling a configuration kwarg and passing it to super
        allocate.tap do |obj|
          obj.instance_variable_set :@configuration, configuration
          obj.send :initialize, **args
        end
      end
    end
  end

  module MyApp
    class Action < SomeFramework::Action
      # Inject the configuration object, which is passed to
      # SomeFramework::Action.new but not all the way through to any subsequent
      # `#initialize` calls
      include Import[configuration: "web.action.configuration"]
    end

    class SomeAction < Action
      # Subclasses of MyApp::Action don't need to concern themselves with
      # `configuration` dependency
      include Import["some_repo"]
    end
  end
  ```

[0.5.0]: https://github.com/dry-rb/dry-auto_inject/compare/v0.4.6...v0.5.0

## [0.4.6] - 2018-03-27

### Changed

- In injector-generated `#initialize` methods, set dependency instance variables before calling `super`. (@timriley)

[0.4.6]: https://github.com/dry-rb/dry-auto_inject/compare/v0.4.5...v0.4.6

## [0.4.5] - 2018-01-02

### Added

- Improved handling of kwargs being passed to #initialize’s super method. (@timriley)

[0.4.5]: https://github.com/dry-rb/dry-auto_inject/compare/v0.4.4...v0.4.5

## [0.4.4] - 2017-09-14

### Added

- Determine name for dependencies by splitting identifiers on any invalid local variable name characters (e.g. "/", "?", "!"), instead of splitting on dots only. (@raventid in #39)

[0.4.4]: https://github.com/dry-rb/dry-auto_inject/compare/v0.4.3...v0.4.4

## [0.4.3] - 2017-05-27

### Added

- Push sequential arguments along with keywords in the kwargs strategy. (@hbda + @vladra in #32)

[0.4.3]: https://github.com/dry-rb/dry-auto_inject/compare/v0.4.2...v0.4.3

## [0.4.2] - 2016-10-10

### Fixed

- Fixed issue where injectors for different containers could not be used on different classes in an inheritance hierarchy. (@timriley in #31)

[0.4.2]: https://github.com/dry-rb/dry-auto_inject/compare/v0.4.1...v0.4.2

## [0.4.1] - 2016-08-14

### Changed

- Loosened version dependency on dry-container. (@AMHOL)

[0.4.1]: https://github.com/dry-rb/dry-auto_inject/compare/v0.4.0...v0.4.1

## [0.4.0] - 2016-07-26

### Added

- Support for strategy chaining, which is helpful in opting for alternatives to an application's normal strategy. (@timriley in #25)

  ```ruby
  # Define the application's injector with a non-default
  MyInject = Dry::AutoInject(MyContainer).hash

  # Opt for a different strategy in a particular class
  class MyClass
    include MyInject.args["foo"]
  end

  # You can chain as long as you want (silly example to demonstrate the flexibility)
  class OtherClass
    include MyInject.args.hash.kwargs.args["foo"]
  end
  ```

### Fixed

- Fixed issue with kwargs injectors used at multiple points in a class inheritance heirarchy. (@flash-gordon in #27)

### Changed

- Use a `BasicObject`-based environment for the injector builder API instead of the previous `define_singleton_method`-based approach, which had negative performance characteristics. (@timriley in #26)

[0.4.0]: https://github.com/dry-rb/dry-auto_inject/compare/v0.3.0...v0.4.0

## [0.3.0] - 2016-06-02

### Added

- Support for new `kwargs` and `hash` injection strategies

  These strategies can be accessed via methods on the main builder object:

  ```ruby
  MyInject = Dry::AutoInject(my_container)

  class MyClass
    include MyInject.hash["my_dep"]
  end
  ```
- Support for user-provided injection strategies

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
- User-specified aliases for dependencies

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
- Inspect the `super` method of the including class’s `#initialize` and send it arguments that will match its own arguments list/arity. This allows auto_inject to be used more easily in existing class inheritance heirarchies.

### Changed

- `kwargs` is the new default injection strategy
- Rubinius support is not available for the `kwargs` strategy (see [#18](https://github.com/dry-rb/dry-auto_inject/issues/18))

[0.3.0]: https://github.com/dry-rb/dry-auto_inject/compare/v0.2.0...v0.3.0

## [0.2.0] - 2016-02-09

### Added

- Support for hashes as constructor arguments via `Import.hash` interface. (@solnic)

[0.2.0]: https://github.com/dry-rb/dry-auto_inject/compare/v0.1.0...v0.2.0

## [0.1.0] - 2015-11-12

Changed interface from `Dry::AutoInject.new { container(some_container) }` to

[0.1.0]: https://github.com/dry-rb/dry-auto_inject/compare/v0.0.1...v0.1.0

## [0.0.1] - 2015-08-20

First public release \o/
