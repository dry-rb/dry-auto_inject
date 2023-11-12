# frozen_string_literal: true

require "dry/auto_inject/method_parameters"

RSpec.describe Dry::AutoInject::MethodParameters do
  let(:parameters) { described_class }

  describe ".of" do
    it "returns method parameters" do
      klass = Class.new {
        def foo(a, b = nil, *c, d:, e: nil, **f, &g); end
      }

      all_parameters = parameters.of(klass, :foo).to_a

      expect(all_parameters.size).to eq 1
      expect(all_parameters[0].parameters)
        .to eq([
          [:req, :a], [:opt, :b], [:rest, :c],
          [:keyreq, :d], [:key, :e], [:keyrest, :f],
          [:block, :g]
        ])
    end

    it "returns empty array when no method defined" do
      expect(parameters.of(Object, :non_existing).to_a).to be_empty
    end

    it "returns parameters for build-in methods" do
      all_parameters = parameters.of(BasicObject, :initialize).to_a

      expect(all_parameters.size).to eq 1
      expect(all_parameters[0]).to be_empty
    end

    it "lists methods defined in mixins" do
      klass = Class.new {
        include Module.new {
          def initialize(*)
            super
          end
        }
      }

      all_parameters = parameters.of(klass, :initialize).to_a

      expect(all_parameters.size).to eq 2

      if RUBY_VERSION >= "3.2"
        expect(all_parameters[0].parameters).to eql([[:rest, :*]])
      else
        expect(all_parameters[0].parameters).to eql([[:rest]])
      end
      expect(all_parameters[1]).to be_empty
    end
  end

  describe "#pass_through?" do
    klass = Class.new {
      def arg_kwarg(*, **) = super

      def arg(*) = super

      def kwarg(**) = super

      def ellipsis(...) = super

      if RUBY_VERSION >= "3.1"
        class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          def arg_kwarg_block(*, **, &) = super

          def arg_block(*, &) = super

          def kwarg_block(**, &) = super

        RUBY
      else
        alias_method :arg_kwarg_block, :arg
        alias_method :arg_block, :arg
        alias_method :kwarg_block, :kwarg
      end
    }

    it "returns true for pass-through methods" do
      expect(parameters.of(klass, :arg_kwarg).first).to be_pass_through
      expect(parameters.of(klass, :arg).first).to be_pass_through
      expect(parameters.of(klass, :kwarg).first).to be_pass_through
      expect(parameters.of(klass, :arg_block).first).to be_pass_through
      expect(parameters.of(klass, :kwarg_block).first).to be_pass_through
    end

    it "returns false for non-pass-through methods" do
      # ellipsis are treated differently because
      # it can be used for delegation to methods other than super
      expect(parameters.of(klass, :ellipsis).first).not_to be_pass_through
      # same signature
      expect(parameters.of(klass, :arg_kwarg_block).first).not_to be_pass_through
    end
  end
end
