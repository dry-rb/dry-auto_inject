require 'dry-initializer'
require 'dry/auto_inject/version'

module Dry
  # Configure an auto-injection module
  #
  # @example
  #    module MyApp
  #      # set up your container
  #      container = Dry::Container.new
  #
  #      container.register(:data_store, -> { DataStore.new })
  #      container.register(:user_repository, -> { container[:data_store][:users] })
  #      container.register(:persist_user, -> { PersistUser.new })
  #
  #      # set up your auto-injection function
  #      AutoInject = Dry::AutoInject(container)
  #
  #      # define your injection function
  #      def self.Inject(*keys)
  #        AutoInject[*keys]
  #      end
  #    end
  #
  #    # then simply include it in your class providing which dependencies should be
  #    # injected automatically from the configured container
  #    class PersistUser
  #      include MyApp::Inject(:user_repository)
  #
  #      def call(user)
  #        user_repository << user
  #      end
  #    end
  #
  #    persist_user = container[:persist_user]
  #
  #    persist_user.call(name: 'Jane')
  #
  # @return [Proc] calling the returned proc builds an auto-injection module
  #
  # @api public
  def self.AutoInject(container)
    Injection.new(container)
  end

  class Injection
    attr_reader :container, :options

    # @api private
    def initialize(container, options = {})
      @container = container
      @options = options
    end

    # @api public
    def hash
      self.class.new(container, options.merge(type: :hash))
    end

    # @api public
    def [](*names)
      AutoInject.new(names, container, options)
    end
  end

  # @api private
  class AutoInject < Module
    attr_reader :names

    attr_reader :container

    attr_reader :instance_mod

    attr_reader :ivars

    attr_reader :options

    attr_reader :type

    # @api private
    def initialize(names, container, options = {})
      @names = names
      @container = container
      @options = options
      @type = options.fetch(:type, :args)
      @ivars = names.map(&:to_s).map { |s| s.split('.').last }.map(&:to_sym)
      @instance_mod = Module.new
    end

    # @api private
    def included(klass)
      define_initializer(klass)
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
      end
    end

    # @api private
    def define_new_method_with_args(klass)
      klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.new(*args)
          names = [#{names.map(&:inspect).join(', ')}]
          deps = names.map.with_index { |_, i| args[i] || container[names[i]] }
          super(*deps)
        end
      RUBY
    end

    # @api private
    def define_new_method_with_hash(klass)
      klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.new(options = {})
          names = [#{names.map(&:inspect).join(', ')}]
          deps = names.each_with_object({}) { |k, r|
            r[k.to_s.split('.').last.to_sym] = options[k] || container[k]
          }.merge(options)
          super(deps)
        end
      RUBY
    end

    # @api private
    def define_initializer(klass)
      case type
      when :args then define_initializer_with_args(klass)
      when :hash then define_initializer_with_hash(klass)
      end
    end

    # @api private
    def define_initializer_with_args(klass)
      klass.class_exec(ivars) do |ivars|
        extend Dry::Initializer

        ivars.each do |name|
          param name
        end
      end
    end

    # @api private
    def define_initializer_with_hash(klass)
      klass.class_exec(ivars) do |ivars|
        extend Dry::Initializer

        ivars.each do |name|
          option name
        end
      end
    end
  end
end
