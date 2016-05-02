module Dry
  module AutoInject
    # @api private
    class Injection < Module
      InstanceMethods = Class.new(Module)

      attr_reader :dependency_map

      attr_reader :container

      attr_reader :instance_mod

      attr_reader :options

      attr_reader :type

      # @api private
      def initialize(dependency_map, container, options = {})
        @dependency_map = dependency_map
        @container = container
        @options = options
        @type = options.fetch(:type, :args)
        @instance_mod = InstanceMethods.new
      end

      # @api private
      def included(klass)
        define_constructor(klass)
        define_readers
        define_new_method(klass)
        define_container(klass)

        klass.send(:include, instance_mod)

        super
      end

      private

      # @api private
      def define_container(klass)
        klass.instance_variable_set('@container', container)

        klass.class_eval do
          def self.container
            if superclass.respond_to?(:container)
              superclass.container
            else
              @container
            end
          end
        end
      end

      # @api private
      def define_new_method(klass)
        case type
        when :args then define_new_method_with_args(klass)
        when :hash then define_new_method_with_hash(klass)
        when :kwargs then define_new_method_with_kwargs(klass)
        end
      end

      # @api private
      def define_new_method_with_args(klass)
        klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def self.new(*args)
            names = #{dependency_map.dependencies.inspect}
            deps = names.values.map.with_index { |identifier, i| args[i] || container[identifier] }
            super(*deps)
          end
        RUBY
      end

      # @api private
      def define_new_method_with_hash(klass)
        klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def self.new(options = {})
            names = #{dependency_map.dependencies.inspect}
            deps = names.each_with_object({}) { |(name, identifier), obj|
              obj[name] = options[name] || container[identifier]
            }.merge(options)
            super(deps)
          end
        RUBY
      end

      # @api private
      def define_new_method_with_kwargs(klass)
        klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def self.new(**args)
            names = #{dependency_map.dependencies.inspect}
            deps = names.each_with_object({}) { |(name, identifier), obj|
              obj[name] = args[name] || container[identifier]
            }.merge(args)
            super(**deps)
          end
        RUBY
      end

      # @api private
      def define_constructor(klass)
        case type
        when :args then define_constructor_with_args(klass)
        when :hash then define_constructor_with_hash(klass)
        when :kwargs then define_constructor_with_kwargs(klass)
        end
      end

      # @api private
      def define_constructor_with_args(klass)
        super_method = Dry::AutoInject.super_method(klass, :initialize)
        super_params = if super_method.parameters.empty?
          ''
        elsif super_method.parameters.any? { |type, _| type == :rest }
          '*args'
        else
          "*args[0..#{super_method.parameters.length - 1}]"
        end

        instance_mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def initialize(*args)
            super(#{super_params})
            #{dependency_map.names.map.with_index { |name, i| "@#{name} = args[#{i}]" }.join("\n")}
          end
        RUBY
        self
      end

      # @api private
      def define_constructor_with_hash(klass)
        super_method = Dry::AutoInject.super_method(klass, :initialize)
        super_params = super_method.parameters.empty? ? '' : 'options'

        instance_mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def initialize(options)
            super(#{super_params})
            #{dependency_map.names.map { |name| "@#{name} = options[:#{name}]" }.join("\n")}
          end
        RUBY
        self
      end

      # @api private
      def define_constructor_with_kwargs(klass)
        super_method = Dry::AutoInject.super_method(klass, :initialize)
        super_params = super_method.parameters.empty? ? '' : '**args'

        instance_mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def initialize(**args)
            super(#{super_params})
            #{dependency_map.names.map { |name| "@#{name} = args[:#{name}]" }.join("\n")}
          end
        RUBY
        self
      end

      # @api private
      def define_readers
        instance_mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          attr_reader #{dependency_map.names.map { |name| ":#{name}" }.join(', ')}
        RUBY
        self
      end
    end
  end
end
