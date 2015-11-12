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
    -> *names { AutoInject.new(names, container) }
  end

  # @api private
  class AutoInject < Module
    attr_reader :names

    attr_reader :container

    attr_reader :instance_mod

    attr_reader :ivars

    # @api private
    def initialize(names, container)
      @names = names
      @container = container
      @ivars = names.map(&:to_s).map { |s| s.split('.').last }.map(&:to_sym)
      @instance_mod = Module.new
      define_constructor
    end

    # @api private
    def included(klass)
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
      klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.new(*args)
          names = [#{names.map(&:inspect).join(', ')}]
          deps = names.map.with_index { |_, i| args[i] || container[names[i]] }
          super(*deps)
        end
      RUBY
    end

    # @api private
    def define_constructor
      instance_mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        attr_reader #{ivars.map { |name| ":#{name}" }.join(', ')}

        def initialize(*args)
          super()
          #{ivars.map.with_index { |name, i| "@#{name} = args[#{i}]" }.join("\n")}
        end
      RUBY
      self
    end
  end
end
