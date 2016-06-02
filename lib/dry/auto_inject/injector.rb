require 'dry/auto_inject/strategies'

module Dry
  module AutoInject
    class Injector
      # @api private
      attr_reader :container

      # @api private
      attr_reader :namespace_separator

      # @api private
      attr_reader :strategy

      # @api private
      def initialize(container, namespace_separator, strategy)
        @container = container
        @namespace_separator = namespace_separator
        @strategy = strategy
      end

      def [](*dependency_names)
        strategy.new(container, namespace_separator, *dependency_names)
      end
    end
  end
end
