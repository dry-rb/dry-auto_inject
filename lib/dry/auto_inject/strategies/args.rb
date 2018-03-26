# frozen_string_literal: true

require 'dry/auto_inject/strategies/constructor'

module Dry
  module AutoInject
    class Strategies
      # @api private
      class Args < Constructor
        private

        def define_new
          class_mod.class_exec(container, dependency_map) do |container, dependency_map|
            define_method :new do |*args|
              deps = dependency_map.to_h.values.map.with_index { |identifier, i|
                args[i] || container[identifier]
              }

              super(*deps, *args[deps.size..-1])
            end
          end
        end

        def define_initialize(klass)
          super_method = find_super(klass, :initialize)

          if super_method.nil? || super_method.parameters.empty?
            define_initialize_with_params
          else
            define_initialize_with_splat(super_method)
          end
        end

        def define_initialize_with_params
          initialize_args = dependency_map.names.join(', ')

          instance_mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def initialize(#{initialize_args})
              #{dependency_map.names.map { |name| "@#{name} = #{name}" }.join("\n")}
              super()
            end
          RUBY
        end

        def define_initialize_with_splat(super_method)
          super_params = if super_method.parameters.any? { |type, _| type == :rest }
            '*args'
          else
            "*args[0..#{super_method.parameters.length - 1}]"
          end

          instance_mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def initialize(*args)
              #{dependency_map.names.map.with_index { |name, i| "@#{name} = args[#{i}]" }.join("\n")}
              super(#{super_params})
            end
          RUBY
        end

        def find_super(klass, method_name)
          super_method = Dry::AutoInject.super_method(klass, method_name)

          # Look upwards past `def foo(*)` methods until we get an explicit list of parameters
          while super_method && super_method.parameters == [[:rest]]
            super_method = Dry::AutoInject.super_method(super_method.owner, :initialize)
          end

          super_method
        end
      end

      register :args, Args
    end
  end
end
