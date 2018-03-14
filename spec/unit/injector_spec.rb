# frozen_string_literal: true

require "dry/auto_inject/injector"

RSpec.describe Dry::AutoInject::Builder do
  describe "#respond_to?" do
    subject(:injector) { Dry::AutoInject::Injector.new({}, double("strategy"), builder: builder) }

    let(:builder) { Dry::AutoInject::Builder.new({}, strategies: {kwargs: double("strategy")}) }

    it "responds to #[] as the main injection method" do
      expect(injector.respond_to?(:[])).to be true
    end

    it "responds to the builder's strategy names" do
      expect(injector.respond_to?(:kwargs)).to be true
    end

    it "does not respond to unknown strategy names" do
      expect(injector.respond_to?(:args)).to be false
    end

    %i[container strategy builder].each do |reader|
      it "responds to the #{reader} attr reader" do
        expect(injector.respond_to?(reader)).to be true
      end
    end
  end
end
