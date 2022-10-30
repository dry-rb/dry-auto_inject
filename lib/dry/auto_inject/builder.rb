# frozen_string_literal: true

module Dry
  module AutoInject
    class Builder
      # @api private
      attr_reader :container

      # @api private
      attr_reader :strategies

      # This clashes with the hash strategy
      undef hash

      def initialize(container, options = {})
        @container = container
        @strategies = options.fetch(:strategies) { Strategies }
      end

      # @api public
      def [](*dependency_names)
        default[*dependency_names]
      end

      def respond_to_missing?(name, _include_private = false)
        strategies.key?(name)
      end

      private

      def method_missing(name, *args, &block)
        if strategies.key?(name)
          Injector.new(container, strategies[name], builder: self)
        else
          super
        end
      end
    end
  end
end
