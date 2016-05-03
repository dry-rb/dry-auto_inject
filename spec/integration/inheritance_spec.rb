RSpec.describe "Inheritance" do
  before do
    module Test
      AutoInject = Dry::AutoInject({one: 1, two: 2, 'namespace.three' => 3})
    end
  end

  context "auto-inject included from outside a class with an existing initializer to manage ivar assignment" do
    let(:class_with_initializer) do
      Class.new do
        attr_reader :one

        def initialize(one)
          @one = one
        end
      end
    end

    it "passes dependencies to the initializer" do
      # This example only works on more modern Ruby version (2.1 and newer)
      return unless Class.instance_methods.include?(:include)

      class_with_initializer.include Test::AutoInject[:one]
      expect(class_with_initializer.new.one).to eq 1
    end
  end
end
