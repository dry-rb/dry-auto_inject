# frozen_string_literal: true

require 'set'
require 'dry/auto_inject/strategies/constructor'

module Dry
  module AutoInject
    class Strategies
      # @api private
      class Kwargs < Constructor
        private

        def define_new
          class_mod.class_exec(container, dependency_map) do |container, dependency_map|
            map = dependency_map.to_h.to_a

            define_method :new do |*args, **kwargs|
              map.each do |name, identifier|
                kwargs[name] ||= container[identifier]
              end

              super(*args, **kwargs)
            end
          end
        end

        def define_initialize(klass)
          super_method = Dry::AutoInject.super_method(klass, :initialize)

          if super_method
            super_parameters = super_method.parameters
          else
            super_parameters = []
          end

          super_seq = super_parameters.any? { |type, _|
            type == :req || type == :opt || type == :rest
          }

          if super_seq
            define_initialize_with_splat(super_parameters)
          else
            define_initialize_with_keywords(super_parameters)
          end

          self
        end

        def assign_dependencies(kwargs, destination)
          dependency_map.names.each do |name|
            # Assign instance variables, but only if the ivar is not
            # previously defined (this improves compatibility with objects
            # initialized in unconventional ways)
            unless kwargs[name].nil? && destination.instance_variable_defined?(:"@#{name}")
              destination.instance_variable_set :"@#{name}", kwargs[name]
            end
          end
        end

        def define_initialize_with_keywords(super_parameters)
          super_kwarg_names = super_parameters.each_with_object(Set.new) { |(type, name), names|
            names << name if type == :key || type == :keyreq
          }

          assign_dependencies = method(:assign_dependencies)

          instance_mod.class_exec(dependency_map) do |dependency_map|
            define_method :initialize do |**kwargs|
              assign_dependencies.(kwargs, self)

              super_kwargs = kwargs.select do |key|
                !dependency_map.names.include?(key) || super_kwarg_names.include?(key)
              end

              if super_kwargs.any?
                super(super_kwargs)
              else
                super()
              end
            end
          end
        end

        def define_initialize_with_splat(super_parameters)
          super_kwarg_names = super_parameters.each_with_object(Set.new) { |(type, name), names|
            names << name if type == :key || type == :keyreq
          }

          assign_dependencies = method(:assign_dependencies)
          super_with_splat = super_parameters.any? { |type, _| type == :rest }

          instance_mod.class_exec(dependency_map) do |dependency_map|
            define_method :initialize do |*args, **kwargs|
              assign_dependencies.(kwargs, self)

              if super_with_splat
                super(*args, kwargs)
              else
                super_kwargs = kwargs.select do |key|
                  !dependency_map.names.include?(key) || super_kwarg_names.include?(key)
                end

                if super_kwargs.any?
                  super(*args, super_kwargs)
                else
                  super(*args)
                end
              end
            end
          end

          self
        end
      end

      register_default :kwargs, Kwargs
    end
  end
end
