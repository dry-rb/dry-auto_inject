# frozen_string_literal: true

module Dry
  module AutoInject
    # @api private
    class MethodParameters
      def self.of(obj, name)
        ::Enumerator.new do |y|
          begin
            method = obj.instance_method(name)
          rescue ::NameError # rubocop: disable Lint/SuppressedException
          end

          loop do
            break if method.nil?

            y << MethodParameters.new(method.parameters)
            method = method.super_method
          end
        end
      end

      attr_reader :parameters

      def initialize(parameters)
        @parameters = parameters
      end

      def splat?
        return @splat if defined? @splat

        @splat = parameters.any? { |type, _| type == :rest }
      end

      def sequential_arguments?
        return @sequential_arguments if defined? @sequential_arguments

        @sequential_arguments = parameters.any? do |type, _|
          type == :req || type == :opt
        end
      end

      def keyword_names
        @keyword_names ||= parameters.each_with_object(::Set.new) do |(type, name), names|
          names << name if type == :key || type == :keyreq
        end
      end

      def keyword?(name) = keyword_names.include?(name)

      def empty? = parameters.empty?

      def length = parameters.length

      def pass_through?
        return false if parameters.empty?

        parameters.all? do |param|
          param in [:rest, :*] | [:keyrest, :**]
        end
      end

      EMPTY = new([])
    end
  end
end
