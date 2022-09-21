# frozen_string_literal: true

RSpec.describe "chaining injectors" do
  before do
    module Test
      AutoInject = Dry::AutoInject({one: 1, two: 2})
    end
  end

  let(:class_with_inject) {
    Class.new do
      include Test::AutoInject.args.kwargs[:one, :two]
    end
  }

  it "supports chaining injectors" do
    object = class_with_inject.new
    expect(object.send(:one)).to eq 1
    expect(object.send(:two)).to eq 2

    object = class_with_inject.new(one: "one", two: "two")
    expect(object.send(:one)).to eq "one"
    expect(object.send(:two)).to eq "two"
  end
end
