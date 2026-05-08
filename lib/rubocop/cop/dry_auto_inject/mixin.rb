# frozen_string_literal: true

require "dry/core"

module RuboCop
  module Cop
    module DryAutoInject
      # Shared helpers for cops that inspect `Import[...]`-style calls produced
      # by dry-auto_inject.
      module Mixin
        include ::Dry::Core::Constants

        private

        def injector_call?(node)
          return false unless node.send_type?
          return false unless node.method?(:[])

          receiver = node.receiver
          return false unless receiver&.const_type?

          match_injector_module?(receiver)
        end

        def match_injector_module?(const_node)
          full = const_fullname(const_node)
          clean = full.sub(/\A::/, "")

          Array(cop_config["InjectorModules"]).any? do |entry|
            match_injector_entry?(entry.to_s, full, clean)
          end
        end

        # Entry formats:
        #   - `/pattern/flags`    — regex literal, matched against `clean`
        #   - `*::Name`           — last segment match with any prefix (incl. empty)
        #   - otherwise           — exact match on the full or leading-`::`-stripped path
        def match_injector_entry?(entry, full, clean)
          if entry.start_with?("/")
            regex = parse_regex_entry(entry)
            return false unless regex

            regex.match?(clean)
          elsif entry.start_with?("*::")
            suffix = entry[3..]
            clean == suffix || clean.end_with?("::#{suffix}")
          else
            entry == full || entry == clean
          end
        end

        # Returns a Regexp for a `/pattern/flags` literal, or nil if the
        # string is not a regex literal or the pattern is invalid.
        def parse_regex_entry(str)
          m = str.match(%r{\A/(.*)/([imx]*)\z}m)
          return nil unless m

          opts = 0
          opts |= ::Regexp::IGNORECASE if m[2].include?("i")
          opts |= ::Regexp::MULTILINE if m[2].include?("m")
          opts |= ::Regexp::EXTENDED if m[2].include?("x")
          ::Regexp.new(m[1], opts)
        rescue ::RegexpError
          nil
        end

        def const_fullname(const_node)
          parts = []
          current = const_node

          while current
            if current.const_type?
              parts.unshift(current.children[1].to_s)
              current = current.children[0]
            elsif current.cbase_type?
              parts.unshift("")
              current = nil
            else
              return ""
            end
          end

          parts.join("::")
        end

        # Parses the arguments of an `Import[...]` call into a structured form.
        # Returns nil if any argument is not a plain string or symbol-keyed/string-valued pair.
        def parse_injector_deps(node)
          args = node.arguments
          return nil if args.empty?

          hash_arg = args.last if args.last.hash_type?
          string_nodes = hash_arg ? args[...-1] : args

          non_aliased = parse_non_aliased_deps(string_nodes)
          aliased = parse_aliased_deps(hash_arg)
          return nil if non_aliased.nil? || aliased.nil?

          {non_aliased:, aliased:}
        end

        def parse_non_aliased_deps(nodes)
          return nil unless nodes.all?(&:str_type?)

          nodes.map { |arg| {node: arg, alias: nil, path: arg.value} }
        end

        def parse_aliased_deps(hash_arg)
          return EMPTY_ARRAY unless hash_arg
          return nil unless hash_arg.pairs.all? { |p| p.key.sym_type? && p.value.str_type? }

          hash_arg.pairs.map { |p| {node: p, alias: p.key.value.to_s, path: p.value.value} }
        end

        def format_dep(dep)
          node = dep[:node]
          if dep[:alias]
            "#{dep[:alias]}: #{node.value.source}"
          else
            node.source
          end
        end

        def line_indent_col(node)
          line = node.source_range.source_line
          line.index(/\S/) || node.source_range.column
        end

        def item_indent_spaces(node)
          args = node.arguments

          if args.any? && args.first.source_range.line > node.source_range.line
            indent(args.first.source_range.column)
          else
            indent(line_indent_col(node) + 2)
          end
        end

        def indent(width)
          " " * width
        end

        def render_deps(node, deps)
          if node.multiline?
            inner_indent = item_indent_spaces(node)
            close_indent = indent(line_indent_col(node))
            lines = deps.map { |d| "#{inner_indent}#{format_dep(d)}," }
            "\n#{lines.join("\n")}\n#{close_indent}"
          else
            deps.map { |d| format_dep(d) }.join(", ")
          end
        end

        def replace_injector_content(corrector, node, deps)
          selector = node.loc.selector
          return unless selector&.source&.start_with?("[")

          corrector.replace(selector.adjust(begin_pos: 1, end_pos: -1), render_deps(node, deps))
        end
      end
    end
  end
end
