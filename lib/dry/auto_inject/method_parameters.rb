# frozen_string_literal: true

require "set"

module Dry
  module AutoInject
    # @api private
    class MethodParameters
      PASS_THROUGH = [
        [%i[rest]],
        [%i[rest], %i[keyrest]],
        [%i[rest *]],
        [%i[rest *], %i[keyrest **]]
      ].freeze

      def self.of(obj, name)
        Enumerator.new do |y|
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

        @sequential_arguments = parameters.any? { |type, _|
          type == :req || type == :opt
        }
      end

      def keyword_names
        @keyword_names ||= parameters.each_with_object(Set.new) { |(type, name), names|
          names << name if type == :key || type == :keyreq
        }
      end

      def keyword?(name)
        keyword_names.include?(name)
      end

      def empty?
        parameters.empty?
      end

      def length
        parameters.length
      end

      def pass_through?
        PASS_THROUGH.include?(parameters)
      end

      EMPTY = new([])
    end
  end
end
