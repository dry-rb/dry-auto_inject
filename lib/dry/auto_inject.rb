require 'dry/auto_inject/version'
require 'dry/auto_inject/injection'

module Dry
  class AutoInject
    attr_reader :injection

    # Configure an auto-injection module
    #
    # @example
    #    # set up your container
    #    my_container = Dry::Container.new
    #
    #    my_container.register(:data_store, -> { DataStore.new })
    #    my_container.register(:user_repository, -> { container[:data_store][:users] })
    #    my_container.register(:persist_user, -> { PersistUser.new })
    #
    #    # set up your auto-injection module
    #
    #    AutoInject = Dry::AutoInject.new { container(my_container) }
    #
    #    # then simply include it in your class providing which dependencies should be
    #    # injected automatically from the configure container
    #    class PersistUser
    #      include AutoInject[:user_repository]
    #
    #      def call(user)
    #        user_repository << user
    #      end
    #    end
    #
    #    persist_user = my_container[:persist_user]
    #
    #    persist_user.call(name: 'Jane')
    #
    # @return [Dry::AutoInject::Injection]
    #
    # @api public
    def self.new(&block)
      dsl = super(&block)
      dsl.injection
    end

    # @api private
    def initialize(&block)
      instance_exec(&block)
      @injection = -> *names { Injection.new(names, @container) }
    end

    # Set up the container for the injection module
    #
    # @api public
    def container(container)
      @container = container
    end
  end
end
