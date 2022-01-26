# frozen_string_literal: true

module Dry
  module AutoInject
    class Strategies
      # @api private
      class Base < Module
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
          klass.send(:include, instance_mod)
          klass.extend(class_mod)

          super
        end
      end
    end
  end
end
