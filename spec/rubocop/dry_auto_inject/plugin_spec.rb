# frozen_string_literal: true

require "rubocop"
require "rubocop/dry_auto_inject/plugin"

RSpec.describe RuboCop::DryAutoInject::Plugin do
  subject(:plugin) { described_class.new }

  describe "#rules" do
    it "loads cop classes into the registry" do
      plugin.rules(nil)

      registry = RuboCop::Cop::Registry.global
      cops = registry.select { |c| c.badge.department_name == "DryAutoInject" }

      expect(cops.map { |c| c.badge.to_s }).to contain_exactly(
        "DryAutoInject/DependencyOrder",
        "DryAutoInject/RedundantAlias"
      )
    end
  end
end
