require 'dry-configurable'

require 'dry/auto_inject/version'

module Dry
  class AutoInject
    attr_reader :injector

    class Mixin < Module
      attr_reader :container

      def initialize(container)
        @container = container
      end

      def included(mod)
        mod.module_eval do
          extend Dry::Configurable

          setting :container
        end

        mod.configure { |config| config.container = container }

        super
      end
    end

    class Injection < Module
      attr_reader :names

      attr_reader :mod

      attr_reader :ivars

      def initialize(names, &block)
        module_exec(&block)
        @names = names
        @ivars = names.map(&:to_s).map { |s| s.split('.').last }.map(&:to_sym)
        @mod = Module.new
        define_constructor
      end

      def included(klass)
        klass.class_eval do
          extend Dry::Configurable

          setting :container
        end

        klass.configure { |config| config.container = self.config.container }

        klass.class_eval <<-RUBY
          def self.new(*args)
            names = [#{names.map(&:inspect).join(', ')}]
            deps = names.map.with_index { |_, i| args[i] || config.container[names[i]] }
            super(*deps)
          end
        RUBY

        klass.send(:include, mod)

        super
      end

      def define_constructor
        mod.class_eval <<-RUBY
          attr_reader #{ivars.map { |name| ":#{name}" }.join(', ')}

          def initialize(*args)
            #{ivars.map.with_index { |name, i| "@#{name} = args[#{i}]" }.join("\n")}
          end
        RUBY
        self
      end
    end

    def self.new(&block)
      dsl = super(&block)
      dsl.injector
    end

    def initialize(&block)
      instance_exec(&block)

      mixin = Mixin.new(@container)

      @injector = -> *names { Injection.new(names) { include(mixin) } }
    end

    def container(container)
      @container = container
    end
  end
end
