# frozen_string_literal: true

require 'dry/auto_inject/method_parameters'

RSpec.describe Dry::AutoInject::MethodParameters do
  let(:parameters) { described_class }

  describe '.of' do
    it 'returns method parameters' do
      klass = Class.new {
        def foo(a, b = nil, *c, d:, e: nil, **f, &g)
        end
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

    it 'returns empty array when no method defined' do
      expect(parameters.of(Object, :non_existing).to_a).to be_empty
    end

    it 'returns parameters for build-in methods' do
      all_parameters = parameters.of(BasicObject, :initialize).to_a

      expect(all_parameters.size).to eq 1
      expect(all_parameters[0]).to be_empty
    end

    it 'lists methods defined in mixins' do
      klass = Class.new {
        include Module.new {
          def initialize(*)
            super
          end
        }
      }

      all_parameters = parameters.of(klass, :initialize).to_a

      expect(all_parameters.size).to eq 2
      expect(all_parameters[0].parameters).to eql([[:rest]])
      expect(all_parameters[1]).to be_empty
    end
  end
end
