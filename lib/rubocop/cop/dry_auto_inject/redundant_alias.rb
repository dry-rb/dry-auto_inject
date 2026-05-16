# frozen_string_literal: true

require_relative "mixin"

module RuboCop
  module Cop
    module DryAutoInject
      # Flags dry-auto_inject imports whose hash key matches the last segment
      # of the path, since dry-auto_inject already derives the dependency name
      # from that segment.
      #
      # @example
      #   # bad
      #   include Import[foo: 'some.path.foo']
      #
      #   # good
      #   include Import['some.path.foo']
      class RedundantAlias < Base
        extend AutoCorrector
        include Mixin

        MSG =
          "Redundant alias `%<alias_name>s:` — dependency key is derived from " \
          "the last segment of `'%<path>s'`."

        def on_send(node)
          return unless injector_call?(node)

          deps = parse_injector_deps(node)
          return if deps.nil?

          redundant = deps[:aliased].select { |d| d[:alias] == d[:path].split(".").last }
          return if redundant.empty?

          canonical = promote_redundant_aliases(deps)

          redundant.each_with_index do |dep, i|
            add_offense(
              dep[:node],
              message: format(MSG, alias_name: dep[:alias], path: dep[:path])
            ) do |corrector|
              next unless i.zero?

              replace_injector_content(corrector, node, canonical)
            end
          end
        end

        private

        def promote_redundant_aliases(deps)
          non_aliased = deps[:non_aliased].dup
          aliased = []

          deps[:aliased].each do |d|
            if d[:alias] == d[:path].split(".").last
              non_aliased << {node: d[:node].value, alias: nil, path: d[:path]}
            else
              aliased << d
            end
          end

          non_aliased + aliased
        end
      end
    end
  end
end
