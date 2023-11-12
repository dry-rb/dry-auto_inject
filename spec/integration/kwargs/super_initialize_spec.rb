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

  describe "passing dependencies where superclass has a splat in arguments" do
    let(:parent_class) {
      Class.new do
        attr_reader :dep, :args

        def initialize(*args)
          @dep = args[0].fetch(:one)
          @args = args
        end
      end
    }

    let(:child_class) {
      Class.new(parent_class) do
        include Test::AutoInject[:one]
      end
    }

    it "passes dependencies assuming the parent class can take them" do
      instance = child_class.new

      expect(instance.one).to eq "dep 1"
      expect(instance.dep).to eq "dep 1"
      expect(instance.args).to eq [one: "dep 1"]
    end
  end

  describe "ignoring pass-through constructors" do
    let(:parent_class) {
      Class.new do
        # rubocop:disable Lint/RedundantCopDisableDirective
        # rubocop:disable Style/RedundantInitialize
        def initialize; end
        # rubocop:enable Style/RedundantInitialize
        # rubocop:enable Lint/RedundantCopDisableDirective
      end
    }

    let(:child_class) {
      Class.new(parent_class) do
        include Module.new {
          def initialize(*)
            super
          end
        }

        include Test::AutoInject[:one]
      end
    }

    it "doesn't pass deps if the final constructor will choke on them" do
      instance = child_class.new

      expect(instance.one).to eq "dep 1"
    end

    context "with keywords" do
      let(:child_class) do
        Class.new(parent_class) do
          include Module.new {
            def initialize(*, **)
              super
            end
          }

          include Test::AutoInject[:one]
        end
      end

      it "doesn't pass deps if the final constructor will choke on them" do
        instance = child_class.new

        expect(instance.one).to eq "dep 1"
      end
    end

    context "only keywords" do
      let(:child_class) do
        Class.new(parent_class) do
          include Module.new {
            def initialize(**)
              super
            end
          }

          include Test::AutoInject[:one]
        end
      end

      it "doesn't pass deps if the final constructor will choke on them" do
        instance = child_class.new

        expect(instance.one).to eq "dep 1"
      end
    end
  end
end
