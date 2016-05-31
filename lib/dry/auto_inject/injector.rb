require 'dry/auto_inject/strategies'

module Dry
  module AutoInject
    class Injector
      # @api private
      attr_reader :container

      # @api private
      attr_reader :strategy

      # @api private
      def initialize(container, strategy)
        @container = container
        @strategy = strategy
      end

      def [](*dependency_names)
        strategy.new(container, *dependency_names)
      end
    end
  end
end
