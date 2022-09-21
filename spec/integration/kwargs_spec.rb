# frozen_string_literal: true

RSpec.describe "kwargs" do
  before do
    module Test
      AutoInject = Dry::AutoInject(one: "dep 1")
    end
  end

  it "supports explicit injection of falsey values" do
    obj = Class.new do
      include Test::AutoInject[:one]
    end

    expect(obj.new.send(:one)).to eq "dep 1"
    expect(obj.new(one: false).send(:one)).to be false
    expect(obj.new(one: nil).send(:one)).to be nil
  end

  it "forwards the block to the constructor" do
    klass = Class.new do
      include Test::AutoInject[:one]

      attr_reader :block

      def initialize(*args, **kwargs, &block)
        super(*args, **kwargs)
        @block = block
      end
    end

    block = -> {}

    klass.new.tap do |obj|
      expect(obj.send(:one)).to eq "dep 1"
      expect(obj.block).to be nil
    end

    klass.new(&block).tap do |obj|
      expect(obj.send(:one)).to eq "dep 1"
      expect(obj.block).to eq block
    end

    klass.new(one: nil, &block).tap do |obj|
      expect(obj.send(:one)).to be nil
      expect(obj.block).to eq block
    end
  end
end
