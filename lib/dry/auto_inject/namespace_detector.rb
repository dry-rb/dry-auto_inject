module Dry
  module AutoInject
    # Detects information about namespaces within a container.
    class NamespaceDetector
      DEFAULT_SEPARATOR = '.'.freeze

      # Instantiates a namespace detector for a container.
      #
      # @param container [Dry::Container, Hash]
      # @param separator [String] The namespace separator.
      def initialize(container, separator = nil)
        @container = container
        @separator = separator if separator
      end

      # The namespace separactor for the container.
      #
      # @api public
      # @return [String]
      def separator
        @separator ||= detect_separator
      end

      private

      # @api private
      attr_reader :container

      # Detects the namespace separator from the container.
      #
      # @api private
      # @return [String] The namespace separator.
      def detect_separator
        if container.respond_to?(:config) && container.config.respond_to?(:namespace_separator)
          container.config.namespace_separator
        else
          DEFAULT_SEPARATOR
        end
      end
    end
  end
end
