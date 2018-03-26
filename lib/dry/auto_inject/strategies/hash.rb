# frozen_string_literal: true

require 'dry/auto_inject/strategies/constructor'

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
          super_method = Dry::AutoInject.super_method(klass, :initialize)
          super_params = super_method.nil? || super_method.parameters.empty? ? '' : 'options'

          instance_mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def initialize(options)
              #{dependency_map.names.map { |name| "@#{name} = options[:#{name}]" }.join("\n")}
              super(#{super_params})
            end
          RUBY
        end
      end

      register :hash, Hash
    end
  end
end
