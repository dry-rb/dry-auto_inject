require 'dry/auto_inject/strategies'
require 'dry/auto_inject/injector'

module Dry
  module AutoInject
    class Builder
      # @api private
      attr_reader :container

      # @api private
      attr_reader :strategies

      def initialize(container, options = {})
        @container = container
        @strategies = options.fetch(:strategies) { Strategies }

        strategies.keys.each do |strategy_name|
          define_singleton_method(strategy_name) do
            strategy = strategies[strategy_name]
            Injector.new(container, strategy)
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
