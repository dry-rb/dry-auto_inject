require 'dry/auto_inject/dependency_map'
require 'dry/auto_inject/injection'

module Dry
  module AutoInject
    class Injector
      attr_reader :container, :options

      # @api private
      def initialize(container, options = {})
        @container = container
        @options = options
      end

      # @api public
      def hash
        self.class.new(container, options.merge(type: :hash))
      end

      # @api public
      def kwargs
        self.class.new(container, options.merge(type: :kwargs))
      end

      # @api public
      def [](*names)
        dependencies = DependencyMap.new(*names)
        Injection.new(dependencies, container, options)
      end
    end
  end
end
