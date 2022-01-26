# frozen_string_literal: true

require "dry/auto_inject/builder"

RSpec.describe Dry::AutoInject::Builder do
  describe "#respond_to?" do
    subject(:builder) { Dry::AutoInject::Builder.new({}, strategies: {kwargs: Object.new}) }

    it "responds to strategy names" do
      expect(builder.respond_to?(:kwargs)).to be true
    end

    it "responds to #[] as a shortcut to the default strategy" do
      expect(builder.respond_to?(:[])).to be true
    end

    it "does not respond to unknown strategy names" do
      expect(builder.respond_to?(:args)).to be false
    end

    %i[container strategies].each do |reader|
      it "responds to the #{reader} attr reader" do
        expect(builder.respond_to?(reader)).to be true
      end
    end
  end
end
