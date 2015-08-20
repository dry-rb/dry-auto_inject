RSpec.describe Dry::AutoInject do
  def assert_valid_object(object)
    expect(object.one).to be(1)
    expect(object.two).to be(2)
    expect(object.three).to be(3)
  end

  it 'works' do
    module Test
      AutoInject = Dry::AutoInject.new do
        container one: 1, two: 2, 'namespace.three' => 3
      end
    end

    parent_class = Class.new do
      include Test::AutoInject[:one, :two, 'namespace.three']

      def self.inherited(other)
        super
      end
    end

    child_class = Class.new(parent_class)
    grand_child_class = Class.new(child_class)

    [
      [], [1, 2, 3], [nil, 2, 3], [1, nil, 3], [1, 2, nil], [nil, nil, 3], [1, nil, nil], [1, nil, 3]
    ].each do |args|
      assert_valid_object(parent_class.new(*args))
      assert_valid_object(child_class.new(*args))
      assert_valid_object(grand_child_class.new(*args))
    end
  end
end
