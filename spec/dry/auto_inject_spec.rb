RSpec.describe Dry::AutoInject do
  it 'works' do
    module Test
      AutoInject = Dry::AutoInject.new do
        container one: 1, two: 2
      end
    end

    klass = Class.new do
      include Test::AutoInject[:one, :two]
    end

    object = klass.new

    expect(object.one).to be(1)
    expect(object.two).to be(2)

    object = klass.new(1, nil)

    expect(object.one).to be(1)
    expect(object.two).to be(2)

    object = klass.new(nil, 2)

    expect(object.one).to be(1)
    expect(object.two).to be(2)

    object = klass.new(nil, nil)

    expect(object.one).to be(1)
    expect(object.two).to be(2)
  end
end
