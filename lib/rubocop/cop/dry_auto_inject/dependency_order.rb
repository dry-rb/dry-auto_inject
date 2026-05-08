# frozen_string_literal: true

require_relative "mixin"

module RuboCop
  module Cop
    module DryAutoInject
      # Enforces a configurable order for dry-auto_inject `Import[...]` deps.
      #
      # Non-aliased deps are emitted first, then aliased deps. Within each
      # section, deps are grouped by matching the configured `Order` patterns
      # and sorted alphabetically inside a group. Each pattern can be:
      #
      #   - `'*'`              — catch-all (at most one; implicitly appended)
      #   - `'prefix.*'`       — prefix wildcard (matches `prefix` and `prefix.*`)
      #   - `'/regex/flags'`   — regex matched against the dep path
      #   - otherwise          — exact path match
      #
      # If `Order` is empty or omits `'*'`, a catch-all `'*'` group is appended
      # implicitly so unmatched deps still have a home.
      #
      # Specific patterns take priority over the `*` catch-all regardless of
      # their position in `Order`.
      #
      # @example Order: ['web.*', '*', 'core.*']
      #   # bad
      #   include Import[
      #     'core.db',
      #     'web.router',
      #   ]
      #
      #   # good
      #   include Import[
      #     'web.router',
      #     'core.db',
      #   ]
      #
      # @example Order: ['/\A[^.]+\z/', '*']  — group dotless deps first
      #   include Import[
      #     'logger',
      #     'core.db',
      #   ]
      class DependencyOrder < Base
        extend AutoCorrector
        include Mixin

        MSG = "Dependencies are not in the configured order."

        def initialize(config = nil, options = nil)
          super
          @parsed_order = build_parsed_order
        end

        def on_send(node)
          return unless injector_call?(node)

          deps = parse_injector_deps(node)
          return if deps.nil?

          order = parsed_order
          current = deps[:non_aliased] + deps[:aliased]
          sorted = [deps[:non_aliased], deps[:aliased]].flat_map { |group|
            group_and_sort(group, order) { |d| d[:path] }
          }

          return if current == sorted

          add_offense(node, message: MSG) do |corrector|
            replace_injector_content(corrector, node, sorted)
          end
        end

        private

        attr_reader :parsed_order

        def build_parsed_order
          raw = Array(cop_config["Order"]).dup

          if raw.count("*") > 1
            raise "#{self.class.badge}: `Order` may contain at most one '*' entry " \
                  "(got #{raw.inspect})"
          end

          raw << "*" unless raw.include?("*")
          raw.each { |pat| validate_regex_pattern!(pat) if pat.start_with?("/") }
          raw
        end

        def validate_regex_pattern!(pat)
          return if parse_regex_entry(pat)

          raise "#{self.class.badge}: invalid regex in `Order` entry #{pat.inspect}"
        end

        def group_and_sort(deps, order, &)
          groups = ::Hash.new { |h, k| h[k] = [] }

          # Specific patterns take priority over the `*` catch-all regardless
          # of their position in `Order`.
          specific_patterns = order.reject { |p| p == "*" }

          deps.each do |d|
            pat = specific_patterns.find { |p| match_pattern?(d[:path], p) } || "*"
            groups[pat] << d
          end

          order.flat_map { |p| groups[p].sort_by(&) }
        end

        def match_pattern?(path, pattern)
          return true if pattern == "*"

          if pattern.start_with?("/")
            parse_regex_entry(pattern)&.match?(path)
          elsif pattern.end_with?(".*")
            prefix = pattern[...-2]
            path == prefix || path.start_with?("#{prefix}.")
          else
            path == pattern
          end
        end
      end
    end
  end
end
