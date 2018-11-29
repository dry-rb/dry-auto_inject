# frozen_string_literal: true

require 'dry/auto_inject/strategies/constructor'
require 'dry/auto_inject/method_parameters'

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
          super_parameters = MethodParameters.of(klass, :initialize).each do |ps|
            # Look upwards past `def foo(*)` methods until we get an explicit list of parameters
            break ps unless ps.pass_through?
          end

          if super_parameters.empty?
            define_initialize_with_params
          else
            define_initialize_with_splat(super_parameters)
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

        def define_initialize_with_splat(super_parameters)
          super_pass = if super_parameters.splat?
            '*args'
          else
            "*args.take(#{super_parameters.length})"
          end

          instance_mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def initialize(*args)
              #{dependency_map.names.map.with_index { |name, i| "@#{name} = args[#{i}]" }.join("\n")}
              super(#{super_pass})
            end
          RUBY
        end
      end

      register :args, Args
    end
  end
end
