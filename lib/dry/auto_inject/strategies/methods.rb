# frozen_string_literal: true

require 'dry/auto_inject/strategies/base'
require 'dry/auto_inject/method_parameters'

module Dry
  module AutoInject
    class Strategies
      # @api private
      class Methods < Base
        # @api private
        def included(klass)
          define_class_methods
          define_instance_methods

          super
        end

        private

        def define_class_methods
          class_mod.class_exec(container, dependency_map) do |container, dependency_map|
            dependency_map.to_h.each do |name, identifier|
              define_method name do
                container[identifier]
              end
            end

            def with_deps(**deps)
              Class.new(self) do |klass|
                deps.each do |name, value|
                  singleton_class.define_method name do
                    value
                  end
                end
              end
            end
          end

          self
        end

        def define_instance_methods
          instance_mod.class_exec(container, dependency_map) do |container, dependency_map|
            dependency_map.to_h.each do |name, identifier|
              define_method name do
                self.class.send(name)
              end
            end
          end

          self
        end
      end

      register :methods, Methods
    end
  end
end
