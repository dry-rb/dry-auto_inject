require 'dry/auto_inject/version'
require 'dry/auto_inject/injection'

module Dry
  class AutoInject
    attr_reader :injection

    def self.new(&block)
      dsl = super(&block)
      dsl.injection
    end

    def initialize(&block)
      instance_exec(&block)
      @injection = -> *names { Injection.new(names, @container) }
    end

    def container(container)
      @container = container
    end
  end
end
