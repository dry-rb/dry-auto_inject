require 'set'

module Dry
  module AutoInject
    # @api private
    class MethodParameters
      PASS_THROUGH = [[:rest]]

      if RUBY_VERSION >= '2.4.4.' && !defined? JRUBY_VERSION
        def self.of(obj, name)
          Enumerator.new do |y|
            begin
              method = obj.instance_method(name)
            rescue NameError
            end

            loop do
              break if method.nil?

              y << MethodParameters.new(method.parameters)
              method = method.super_method
            end
          end
        end
      else
        # see https://bugs.ruby-lang.org/issues/13973
        def self.of(obj, name)
          Enumerator.new do |y|
            ancestors = obj.ancestors

            loop do
              klass = ancestors.shift
              break if klass.nil?

              begin
                method = klass.instance_method(name)

                next unless method.owner.equal?(klass)
              rescue NameError
                next
              end

              y << MethodParameters.new(method.parameters)
            end
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
        parameters.eql?(PASS_THROUGH)
      end

      EMPTY = new([])
    end
  end
end
