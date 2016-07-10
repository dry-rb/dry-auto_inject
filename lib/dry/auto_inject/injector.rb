require 'dry/auto_inject/strategies'

module Dry
  module AutoInject
    class Injector < BasicObject
      # @api private
      attr_reader :container

      # @api private
      attr_reader :strategy

      # @api private
      attr_reader :builder

      # @api private
      def initialize(container, strategy, builder:)
        @container = container
        @strategy = strategy
        @builder = builder
      end

      def [](*dependency_names)
        strategy.new(container, *dependency_names)
      end

      def method_missing(name, *args, &block)
        builder.send(name)
      end
    end
  end
end
