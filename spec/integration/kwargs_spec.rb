# frozen_string_literal: true

RSpec.describe "kwargs" do
  it "supports explicit injection of falsey values" do
    module Test
      AutoInject = Dry::AutoInject(one: "dep 1")
    end

    obj = Class.new do
      include Test::AutoInject[:one]
    end

    expect(obj.new.one).to eq "dep 1"
    expect(obj.new(one: false).one).to be false
    expect(obj.new(one: nil).one).to be nil
  end
end
