# frozen_string_literal: true

require "dry/auto_inject/strategies"

module Dry
  module AutoInject
    class Injector < BasicObject
      # @api private
      attr_reader :container

      # @api private
      attr_reader :strategy

      # @api private
      attr_reader :builder

      define_method(:respond_to?, ::Kernel.instance_method(:respond_to?))

      # @api private
      def initialize(container, strategy, builder:)
        @container = container
        @strategy = strategy
        @builder = builder
      end

      def [](*dependency_names)
        strategy.new(container, *dependency_names)
      end

      def respond_to_missing?(name, _include_private = false)
        builder.respond_to?(name)
      end

      private

      def method_missing(name, *_args)
        builder.__send__(name)
      end
    end
  end
end
