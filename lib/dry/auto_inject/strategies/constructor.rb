# frozen_string_literal: true

require 'dry/auto_inject/dependency_map'

module Dry
  module AutoInject
    class Strategies
      class Constructor < Module
        ClassMethods = Class.new(Module)
        InstanceMethods = Class.new(Module)

        attr_reader :container
        attr_reader :dependency_map
        attr_reader :instance_mod
        attr_reader :class_mod

        def initialize(container, *dependency_names)
          @container = container
          @dependency_map = DependencyMap.new(*dependency_names)
          @instance_mod = InstanceMethods.new
          @class_mod = ClassMethods.new
        end

        # @api private
        def included(klass)
          define_readers

          define_new
          define_initialize(klass)

          klass.send(:include, instance_mod)
          klass.extend(class_mod)

          super
        end

        private

        def define_readers
          instance_mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            attr_reader #{dependency_map.names.map { |name| ":#{name}" }.join(', ')}
          RUBY
          self
        end

        def define_new
          raise NotImplementedError, "must be implemented by a subclass"
        end

        def define_initialize(klass)
          raise NotImplementedError, "must be implemented by a subclass"
        end
      end
    end
  end
end
