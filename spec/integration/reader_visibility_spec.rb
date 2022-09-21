# frozen_string_literal: true

RSpec.describe "Reader visibility" do
  shared_examples "private readers" do
    before do
      module Test
        AutoInject = Dry::AutoInject(one: "dep 1")
      end
    end

    it "creates private readers by default" do
      strategy = self.strategy

      object = Class.new {
        include Test::AutoInject.send(strategy)[:one]
      }.new

      expect(object).not_to respond_to(:one)
      expect(object.send(:one)).to eq "dep 1"
    end

    it "can have its readers made public" do
      strategy = self.strategy

      object = Class.new {
        include Test::AutoInject.send(strategy)[:one]
        public :one
      }.new

      expect(object).to respond_to(:one)
      expect(object.one).to eq "dep 1"
    end
  end

  describe "kwargs" do
    let(:strategy) { :kwargs }
    it_behaves_like "private readers"
  end

  describe "hash" do
    let(:strategy) { :hash }
    it_behaves_like "private readers"
  end

  describe "args" do
    let(:strategy) { :args }
    it_behaves_like "private readers"
  end
end
