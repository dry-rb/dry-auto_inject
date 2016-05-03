RSpec.describe "Inheritance" do
  let(:container) { { one: 1, two: 2, 'namespace.three' => 3 } }
  let(:auto_inject) { Dry::AutoInject(container) }

  context "auto-inject included from outside a class with an existing initializer" do
    let(:class_with_initializer) do
      Class.new do
        attr_reader :foo

        def initialize(foo)
          @foo = foo
        end
      end
    end

    it "passes dependencies to the initializer" do
      class_with_initializer.include(auto_inject[:one])
      expect(class_with_initializer.new.foo).to eq 1
    end
  end
end
