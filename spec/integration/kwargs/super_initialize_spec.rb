RSpec.describe "kwargs / super #initialize method" do
  before do
    module Test
      AutoInject = Dry::AutoInject({one: "dep 1"})
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
