# frozen_string_literal: true

require 'dry/auto_inject/strategies/constructor'
require 'dry/auto_inject/method_parameters'

module Dry
  module AutoInject
    class Strategies
      # @api private
      class Hash < Constructor
        private

        def define_new
          class_mod.class_exec(container, dependency_map) do |container, dependency_map|
            define_method :new do |options = {}|
              deps = dependency_map.to_h.each_with_object({}) { |(name, identifier), obj|
                obj[name] = options[name] || container[identifier]
              }.merge(options)

              super(deps)
            end
          end
        end

        def define_initialize(klass)
          super_params = MethodParameters.of(klass, :initialize).first
          super_pass = super_params.empty? ? '' : 'options'

          instance_mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def initialize(options)
              #{dependency_map.names.map { |name| "@#{name} = options[:#{name}] unless !options.key?(#{name}) && instance_variable_defined?(:'@#{name}')" }.join("\n")}
              super(#{super_pass})
            end
          RUBY
        end
      end

      register :hash, Hash
    end
  end
end
