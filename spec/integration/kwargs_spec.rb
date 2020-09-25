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

    expect(obj.new.one).to eq "dep 1"
    expect(obj.new(one: false).one).to be false
    expect(obj.new(one: nil).one).to be nil
  end

  it "forwards the block to the constructor" do
    klass = Class.new do
      include Test::AutoInject[:one]

      attr_reader :block

      def initialize(*args, &block)
        super(*args)
        @block = block
      end
    end

    block = -> {}

    expect(klass.new).to have_attributes(one: "dep 1", block: nil)
    expect(klass.new(&block)).to have_attributes(one: "dep 1", block: block)
    expect(klass.new(one: nil, &block)).to have_attributes(one: nil, block: block)
  end
end
