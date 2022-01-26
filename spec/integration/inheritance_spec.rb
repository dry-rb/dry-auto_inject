# frozen_string_literal: true

RSpec.describe "Inheritance" do
  before do
    module Test
      AutoInject = Dry::AutoInject({one: 1, two: 2, "namespace.three" => 3})
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
      skip unless Class.instance_methods.include?(:include)

      class_with_initializer.include Test::AutoInject.args[:one]
      expect(class_with_initializer.new.one).to eq 1
    end
  end

  context "injectors for different containers in inherited classes" do
    before do
      module Test
        InjectOne = Dry::AutoInject(one: "hi from one")
        InjectTwo = Dry::AutoInject(two: "hi from two")

        class One
          include InjectOne[:one]
        end

        class Two < One
          include InjectTwo[:two]
        end
      end
    end

    it "uses the dependencies from each of the containers" do
      instance = Test::Two.new
      expect(instance.one).to eq "hi from one"
      expect(instance.two).to eq "hi from two"
    end

    it "allows either dependency to be overridden" do
      expect(Test::Two.new(one: "manual one").one).to eq "manual one"
      expect(Test::Two.new(two: "manual two").two).to eq "manual two"
    end
  end
end
