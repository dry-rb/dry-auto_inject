# frozen_string_literal: true

RSpec.describe "kwargs / super #initialize method" do
  before do
    module Test
      AutoInject = Dry::AutoInject(one: "dep 1")
    end
  end

  describe "super #initialize using dependencies set in the child class" do
    context "super #initialize without parameters" do
      let(:parent_class) {
        Class.new do
          attr_reader :excited_one

          def initialize
            @excited_one = "#{one}!"
          end
        end
      }

      let(:child_class) {
        Class.new(parent_class) do
          include Test::AutoInject[:one]
        end
      }

      it "sets the dependencies in the generated #initialize before calling super" do
        expect(child_class.new.excited_one).to eq "dep 1!"
      end
    end

    context "super #initialize with parameters" do
      let(:parent_class) {
        Class.new do
          attr_reader :excited_one

          def initialize(two:)
            @excited_one = "#{one}!"
            @two = two
          end
        end
      }

      let(:child_class) {
        Class.new(parent_class) do
          include Test::AutoInject[:one]
        end
      }

      it "sets the dependenceies in the generated #initialize before caling super" do
        expect(child_class.new(two: "_").excited_one).to eq "dep 1!"
      end
    end
  end

  describe "super #initialize accepts *args and extracts keyword args manually" do
    let(:parent_class) {
      Class.new do
        attr_reader :data

        def initialize(*args)
          kwargs = args.last
          @data = kwargs.fetch(:data)
        end
      end
    }

    let(:child_class) {
      Class.new(parent_class) do
        include Test::AutoInject[:one]
      end
    }

    it "passes non-dependency keyword args to the super method" do
      instance = child_class.new(data: "data")

      expect(instance.data).to eq "data"
      expect(instance.one).to eq "dep 1"
    end
  end
end
