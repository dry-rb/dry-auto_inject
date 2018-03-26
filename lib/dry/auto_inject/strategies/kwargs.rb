# frozen_string_literal: true

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

          if super_method.nil? || super_method.parameters.empty?
            define_initialize_with_keywords
          else
            define_initialize_with_splat(super_method)
          end

          self
        end

        def define_initialize_with_keywords
          initialize_params = dependency_map.names.map { |name| "#{name}: nil" }.join(", ")

          instance_mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def initialize(#{initialize_params})
              #{dependency_map.names.map { |name| "@#{name} = #{name}" }.join("\n")}
              super()
            end
          RUBY

          self
        end

        def define_initialize_with_splat(super_method)
          super_kwarg_names = super_method.parameters.each_with_object([]) { |(type, name), names|
            names << name if [:key, :keyreq].include?(type)
          }

          instance_mod.class_exec(dependency_map) do |dependency_map|
            define_method :initialize do |*args, **kwargs|
              dependency_map.names.each do |name|
                instance_variable_set :"@#{name}", kwargs[name]
              end

              super_kwargs = kwargs.each_with_object({}) { |(key, _), hsh|
                if !dependency_map.names.include?(key) || super_kwarg_names.include?(key)
                  hsh[key] = kwargs[key]
                end
              }

              if super_kwargs.any?
                super(*args, **super_kwargs)
              else
                super(*args)
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
