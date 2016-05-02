module Dry
  module AutoInject
    DuplicateDependencyError = Class.new(StandardError)

    class DependencyMap
      attr_reader :map

      def initialize(*dependencies)
        @map = {}

        dependencies = dependencies.dup
        aliases = dependencies.last.is_a?(Hash) ? dependencies.pop : {}

        dependencies.each do |identifier|
          name = identifier.to_s.split(".").last
          add_dependency(name, identifier)
        end

        aliases.each do |name, identifier|
          add_dependency(name, identifier)
        end
      end

      def dependencies
        @map
      end

      def names
        @map.keys
      end

      private

      def add_dependency(name, identifier)
        name = name.to_sym
        raise DuplicateDependencyError, "name +{name}+ is already used" if @map.key?(name)
        @map[name] = identifier
      end
    end
  end
end
