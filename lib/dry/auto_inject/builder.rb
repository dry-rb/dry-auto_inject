require 'dry/auto_inject/strategies'
require 'dry/auto_inject/injector'
require 'dry/auto_inject/namespace_detector'

module Dry
  module AutoInject
    class Builder
      # @api private
      attr_reader :container

      # @api private
      attr_reader :namespace_separator

      # @api private
      attr_reader :strategies

      def initialize(container, options = {})
        @container = container
        @namespace_separator = NamespaceDetector.new(container, options[:namespace_separator]).separator
        @strategies = options.fetch(:strategies) { Strategies }

        strategies.keys.each do |strategy_name|
          define_singleton_method(strategy_name) do
            strategy = strategies[strategy_name]
            Injector.new(container, namespace_separator, strategy)
          end
        end
      end

      # @api public
      def [](*dependency_names)
        default[*dependency_names]
      end
    end
  end
end
