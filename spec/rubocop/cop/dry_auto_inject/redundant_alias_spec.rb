# frozen_string_literal: true

require "rubocop"
require "rubocop/rspec/support"
require "rubocop/dry_auto_inject"

RSpec.describe RuboCop::Cop::DryAutoInject::RedundantAlias do
  include RuboCop::RSpec::ExpectOffense

  let(:cop_config) { {"InjectorModules" => ["Import"]} }

  let(:config) do
    RuboCop::Config.new(
      "DryAutoInject/RedundantAlias" => cop_config
    )
  end

  subject(:cop) { described_class.new(config) }

  context "when the call is not an injector module" do
    it "registers no offenses" do
      expect_no_offenses(<<~RUBY)
        Foo[bar: 'some.path.bar']
      RUBY
    end
  end

  context "when all aliases are non-redundant" do
    it "registers no offenses" do
      expect_no_offenses(<<~RUBY)
        include Import[foo: 'some.path.bar']
      RUBY
    end
  end

  context "when there are only non-aliased deps" do
    it "registers no offenses" do
      expect_no_offenses(<<~RUBY)
        include Import['some.path.foo', 'other.bar']
      RUBY
    end
  end

  context "when an alias is redundant (single-line)" do
    it "registers an offense and corrects it" do
      expect_offense(<<~RUBY)
        include Import[foo: 'some.path.foo']
                       ^^^^^^^^^^^^^^^^^^^^ Redundant alias `foo:` — dependency key is derived from the last segment of `'some.path.foo'`.
      RUBY

      expect_correction(<<~RUBY)
        include Import['some.path.foo']
      RUBY
    end
  end

  context "when a redundant alias is mixed with a non-redundant alias" do
    it "corrects only the redundant one and keeps hash ordering" do
      expect_offense(<<~RUBY)
        include Import[foo: 'some.path.foo', parse_json: 'json.parse']
                       ^^^^^^^^^^^^^^^^^^^^ Redundant alias `foo:` — dependency key is derived from the last segment of `'some.path.foo'`.
      RUBY

      expect_correction(<<~RUBY)
        include Import['some.path.foo', parse_json: 'json.parse']
      RUBY
    end
  end

  context "when redundant alias appears alongside non-aliased deps" do
    it "promotes the dep to the non-aliased section" do
      expect_offense(<<~RUBY)
        include Import['tracing.tracer', span: 'tracing.span']
                                         ^^^^^^^^^^^^^^^^^^^^ Redundant alias `span:` — dependency key is derived from the last segment of `'tracing.span'`.
      RUBY

      expect_correction(<<~RUBY)
        include Import['tracing.tracer', 'tracing.span']
      RUBY
    end
  end

  context "within a multiline Import block" do
    it "registers offenses and rewrites preserving multiline format" do
      expect_offense(<<~RUBY)
        class Foo
          include Import[
            'tracing.propagate_context',
            attributes_from_hash: 'tracing.attributes_from_hash',
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant alias `attributes_from_hash:` — dependency key is derived from the last segment of `'tracing.attributes_from_hash'`.
            parse_json: 'json.parse',
          ]
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          include Import[
            'tracing.propagate_context',
            'tracing.attributes_from_hash',
            parse_json: 'json.parse',
          ]
        end
      RUBY
    end
  end

  context "when multiple aliases are redundant" do
    it "registers one offense per redundant alias and corrects them all at once" do
      expect_offense(<<~RUBY)
        include Import[foo: 'a.foo', bar: 'b.bar']
                       ^^^^^^^^^^^^ Redundant alias `foo:` — dependency key is derived from the last segment of `'a.foo'`.
                                     ^^^^^^^^^^^^ Redundant alias `bar:` — dependency key is derived from the last segment of `'b.bar'`.
      RUBY

      expect_correction(<<~RUBY)
        include Import['a.foo', 'b.bar']
      RUBY
    end
  end

  context "with a `*::Name` wildcard entry" do
    let(:cop_config) { {"InjectorModules" => ["*::Import"]} }

    it "matches any path ending in the given suffix" do
      expect_offense(<<~RUBY)
        include ::MyApp::SDK::Import[foo: 'some.path.foo']
                                     ^^^^^^^^^^^^^^^^^^^^ Redundant alias `foo:` — dependency key is derived from the last segment of `'some.path.foo'`.
      RUBY

      expect_correction(<<~RUBY)
        include ::MyApp::SDK::Import['some.path.foo']
      RUBY
    end

    it "also matches an unscoped constant with the same name" do
      expect_offense(<<~RUBY)
        include Import[foo: 'some.path.foo']
                       ^^^^^^^^^^^^^^^^^^^^ Redundant alias `foo:` — dependency key is derived from the last segment of `'some.path.foo'`.
      RUBY
    end
  end

  context "when `Import` is configured as a literal entry" do
    let(:cop_config) { {"InjectorModules" => ["Import"]} }

    it "does not match a namespaced constant" do
      expect_no_offenses(<<~RUBY)
        include ::MyApp::SDK::Import[foo: 'some.path.foo']
      RUBY
    end

    it "matches the bare constant with or without a leading `::`" do
      expect_offense(<<~RUBY)
        include Import[foo: 'some.path.foo']
                       ^^^^^^^^^^^^^^^^^^^^ Redundant alias `foo:` — dependency key is derived from the last segment of `'some.path.foo'`.
        include ::Import[bar: 'some.path.bar']
                         ^^^^^^^^^^^^^^^^^^^^ Redundant alias `bar:` — dependency key is derived from the last segment of `'some.path.bar'`.
      RUBY
    end
  end

  context "with a custom InjectorModules list" do
    let(:cop_config) { {"InjectorModules" => ["App::Deps"]} }

    it "matches the configured fully-qualified name" do
      expect_offense(<<~RUBY)
        include App::Deps[foo: 'some.path.foo']
                          ^^^^^^^^^^^^^^^^^^^^ Redundant alias `foo:` — dependency key is derived from the last segment of `'some.path.foo'`.
      RUBY
    end

    it "does not match other constants" do
      expect_no_offenses(<<~RUBY)
        include Import[foo: 'some.path.foo']
      RUBY
    end
  end

  context "with a regex entry in InjectorModules" do
    let(:cop_config) do
      {"InjectorModules" => ['/\AApp::\w+Deps\z/']}
    end

    it "matches constants whose name matches the regex" do
      expect_offense(<<~RUBY)
        include App::CoreDeps[foo: 'some.path.foo']
                              ^^^^^^^^^^^^^^^^^^^^ Redundant alias `foo:` — dependency key is derived from the last segment of `'some.path.foo'`.
      RUBY
    end

    it "does not match constants whose name fails the regex" do
      expect_no_offenses(<<~RUBY)
        include Import[foo: 'some.path.foo']
      RUBY
    end
  end

  context "when InjectorModules mixes literal names and regex entries" do
    let(:cop_config) do
      {"InjectorModules" => ["Import", '/\AApp::\w+Deps\z/i']}
    end

    it "matches either kind of entry" do
      expect_offense(<<~RUBY)
        include Import[foo: 'some.path.foo']
                       ^^^^^^^^^^^^^^^^^^^^ Redundant alias `foo:` — dependency key is derived from the last segment of `'some.path.foo'`.
        include App::CoreDeps[bar: 'some.path.bar']
                              ^^^^^^^^^^^^^^^^^^^^ Redundant alias `bar:` — dependency key is derived from the last segment of `'some.path.bar'`.
      RUBY
    end
  end

  context "when correcting deps that use varied quote styles" do
    it "preserves quotes when promoting an aliased dep to non-aliased" do
      expect_offense(<<~RUBY)
        include Import[foo: "some.path.foo"]
                       ^^^^^^^^^^^^^^^^^^^^ Redundant alias `foo:` — dependency key is derived from the last segment of `'some.path.foo'`.
      RUBY

      expect_correction(<<~RUBY)
        include Import["some.path.foo"]
      RUBY
    end
  end
end
