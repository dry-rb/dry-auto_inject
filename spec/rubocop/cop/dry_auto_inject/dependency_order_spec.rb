# frozen_string_literal: true

require "rubocop"
require "rubocop/rspec/support"
require "rubocop/dry_auto_inject"

RSpec.describe RuboCop::Cop::DryAutoInject::DependencyOrder do
  include RuboCop::RSpec::ExpectOffense

  let(:cop_config) do
    {"InjectorModules" => ["Import"], "Order" => ["*"]}
  end

  let(:config) do
    RuboCop::Config.new(
      "DryAutoInject/DependencyOrder" => cop_config
    )
  end

  subject(:cop) { described_class.new(config) }

  context "when the call is not an injector module" do
    it "registers no offenses" do
      expect_no_offenses(<<~RUBY)
        Foo['b', 'a']
      RUBY
    end
  end

  context "when there is only one dep" do
    it "registers no offenses" do
      expect_no_offenses(<<~RUBY)
        include Import['foo']
      RUBY
    end
  end

  context "when deps are already alphabetically sorted" do
    it "registers no offenses" do
      expect_no_offenses(<<~RUBY)
        include Import['a.thing', 'b.other']
      RUBY
    end
  end

  context "when non-aliased deps need sorting" do
    it "registers an offense and sorts alphabetically" do
      expect_offense(<<~RUBY)
        include Import['b.other', 'a.thing']
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependencies are not in the configured order.
      RUBY

      expect_correction(<<~RUBY)
        include Import['a.thing', 'b.other']
      RUBY
    end
  end

  context "when non-aliased deps are unsorted alongside aliased deps" do
    it "sorts the non-aliased section and keeps aliased deps last" do
      expect_offense(<<~RUBY)
        include Import['b.other', 'a.thing', bar: 'ns.thing']
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependencies are not in the configured order.
      RUBY

      expect_correction(<<~RUBY)
        include Import['a.thing', 'b.other', bar: 'ns.thing']
      RUBY
    end
  end

  context "within a multiline Import block" do
    it "preserves the multiline formatting" do
      expect_offense(<<~RUBY)
        class Foo
          include Import[
                  ^^^^^^^ Dependencies are not in the configured order.
            'tracing.propagate_context',
            'tracing.attributes_from_hash',
            parse_json: 'json.parse',
          ]
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          include Import[
            'tracing.attributes_from_hash',
            'tracing.propagate_context',
            parse_json: 'json.parse',
          ]
        end
      RUBY
    end
  end

  context "with a custom Order groups list" do
    let(:cop_config) do
      {"InjectorModules" => ["Import"], "Order" => ["web.*", "*", "core.*"]}
    end

    it "splits non-aliased deps into groups and sorts within each" do
      expect_offense(<<~RUBY)
        include Import['core.db', 'other.thing', 'web.router', 'core.cache', 'web.auth']
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependencies are not in the configured order.
      RUBY

      expect_correction(<<~RUBY)
        include Import['web.auth', 'web.router', 'other.thing', 'core.cache', 'core.db']
      RUBY
    end

    it "also applies groups to aliased deps" do
      expect_offense(<<~RUBY)
        include Import[cache: 'core.cache', router: 'web.router', thing: 'other.thing']
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependencies are not in the configured order.
      RUBY

      expect_correction(<<~RUBY)
        include Import[router: 'web.router', thing: 'other.thing', cache: 'core.cache']
      RUBY
    end

    it "sorts within an aliased group by path (container key), not by alias" do
      expect_no_offenses(<<~RUBY)
        include Import[zebra: 'web.aaa', alpha: 'web.zzz']
      RUBY
    end
  end

  context "when aliased deps within a group have the same prefix" do
    it "sorts by path, not by alias" do
      expect_offense(<<~RUBY)
        include Import[alpha: 'ns.zzz', zebra: 'ns.aaa']
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependencies are not in the configured order.
      RUBY

      expect_correction(<<~RUBY)
        include Import[zebra: 'ns.aaa', alpha: 'ns.zzz']
      RUBY
    end
  end

  context "when Order has no `*`" do
    let(:cop_config) do
      {"InjectorModules" => ["Import"], "Order" => ["web.*"]}
    end

    it "implicitly appends `*` as the last group" do
      expect_offense(<<~RUBY)
        include Import['core.db', 'web.router']
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependencies are not in the configured order.
      RUBY

      expect_correction(<<~RUBY)
        include Import['web.router', 'core.db']
      RUBY
    end
  end

  context "with a regex Order entry" do
    let(:cop_config) do
      {"InjectorModules" => ["Import"], "Order" => ['/\A[^.]+\z/', "*"]}
    end

    it "puts deps matching the regex first" do
      expect_offense(<<~RUBY)
        include Import['core.db', 'logger', 'web.router', 'cache']
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependencies are not in the configured order.
      RUBY

      expect_correction(<<~RUBY)
        include Import['cache', 'logger', 'core.db', 'web.router']
      RUBY
    end

    it "applies the regex group to aliased deps too" do
      expect_offense(<<~RUBY)
        include Import[db: 'core.db', log: 'logger']
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependencies are not in the configured order.
      RUBY

      expect_correction(<<~RUBY)
        include Import[log: 'logger', db: 'core.db']
      RUBY
    end
  end

  context "with a regex Order entry using flags" do
    let(:cop_config) do
      {"InjectorModules" => ["Import"], "Order" => ['/\AWEB\./i', "*"]}
    end

    it "honours regex flags" do
      expect_offense(<<~RUBY)
        include Import['core.db', 'web.router']
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependencies are not in the configured order.
      RUBY

      expect_correction(<<~RUBY)
        include Import['web.router', 'core.db']
      RUBY
    end
  end

  context "when Order has an invalid regex" do
    let(:cop_config) do
      {"InjectorModules" => ["Import"], "Order" => ["/[unclosed/"]}
    end

    it "raises a configuration error during construction" do
      expect { described_class.new(config) }
        .to raise_error(/invalid regex/)
    end
  end

  context "when Order has a malformed regex literal" do
    let(:cop_config) do
      {"InjectorModules" => ["Import"], "Order" => ["/foo"]}
    end

    it "raises a configuration error during construction" do
      expect { described_class.new(config) }
        .to raise_error(/invalid regex/)
    end
  end

  context "when Order contains more than one `*`" do
    let(:cop_config) do
      {"InjectorModules" => ["Import"], "Order" => ["*", "web.*", "*"]}
    end

    it "raises a configuration error during construction" do
      expect { described_class.new(config) }
        .to raise_error(/at most one '\*'/)
    end
  end

  context "with a `*::Name` wildcard entry" do
    let(:cop_config) do
      {"InjectorModules" => ["*::Import"], "Order" => ["*"]}
    end

    it "matches any path ending in the given suffix" do
      expect_offense(<<~RUBY)
        include ::MyApp::SDK::Import['b', 'a']
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependencies are not in the configured order.
      RUBY

      expect_correction(<<~RUBY)
        include ::MyApp::SDK::Import['a', 'b']
      RUBY
    end
  end

  context "when `Import` is configured as a literal entry" do
    it "does not match a namespaced constant" do
      expect_no_offenses(<<~RUBY)
        include ::MyApp::SDK::Import['b', 'a']
      RUBY
    end
  end

  context "when correcting deps that use varied quote styles" do
    it "preserves double quotes on non-aliased deps" do
      expect_offense(<<~RUBY)
        include Import["b.other", "a.thing"]
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependencies are not in the configured order.
      RUBY

      expect_correction(<<~RUBY)
        include Import["a.thing", "b.other"]
      RUBY
    end

    it "preserves double quotes on aliased dep values" do
      expect_offense(<<~RUBY)
        include Import[alpha: "ns.zzz", zebra: "ns.aaa"]
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependencies are not in the configured order.
      RUBY

      expect_correction(<<~RUBY)
        include Import[zebra: "ns.aaa", alpha: "ns.zzz"]
      RUBY
    end

    it "preserves mixed quote styles per dep" do
      expect_offense(<<~RUBY)
        include Import["b.other", 'a.thing', y: "ns.zzz", x: 'ns.aaa']
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependencies are not in the configured order.
      RUBY

      expect_correction(<<~RUBY)
        include Import['a.thing', "b.other", x: 'ns.aaa', y: "ns.zzz"]
      RUBY
    end
  end
end
