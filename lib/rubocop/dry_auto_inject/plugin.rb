# frozen_string_literal: true

require "lint_roller"

require "dry/auto_inject/version"
require_relative "../cop/dry_auto_inject/dependency_order"
require_relative "../cop/dry_auto_inject/redundant_alias"

module RuboCop
  module DryAutoInject
    class Plugin < ::LintRoller::Plugin
      def about
        ::LintRoller::About.new(
          name: "dry-auto_inject",
          version: ::Dry::AutoInject::VERSION,
          homepage: "https://hanakai.org/learn/dry/dry-auto_inject",
          description: "RuboCop cops for enforcing dry-auto_inject conventions."
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        project_root = ::Pathname.new(__dir__).join("../../..")

        ::LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: project_root.join("config", "default.yml")
        )
      end
    end
  end
end
