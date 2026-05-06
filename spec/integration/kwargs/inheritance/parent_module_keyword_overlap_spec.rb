# frozen_string_literal: true

RSpec.describe "kwargs / inheritance / parent module keyword overlapping injected dep" do
  before do
    module Test
      AutoInject = Dry::AutoInject(one: "dep 1", view: "dep view")
    end
  end

  let(:keyword_module) do
    Module.new do
      def initialize(view: nil, **kwargs)
        @view = view
        super(**kwargs)
      end
    end
  end

  describe "parent includes a module with an explicit keyword, then auto_inject" do
    let(:parent_class) do
      mod = keyword_module
      Class.new do
        include mod
        include Test::AutoInject[:one]
      end
    end

    let(:child_class) do
      Class.new(parent_class) do
        include Test::AutoInject[:view]
      end
    end

    specify "injected dependency matching the module's keyword is preserved" do
      instance = child_class.new
      expect(instance.view).to eq "dep view"
    end

    specify "dependencies from the parent class are also available" do
      instance = child_class.new
      expect(instance.one).to eq "dep 1"
    end
  end

  describe "parent auto_injects, then includes the keyword module (reversed order)" do
    let(:parent_class) do
      mod = keyword_module
      Class.new do
        include Test::AutoInject[:one]
        include mod
      end
    end

    let(:child_class) do
      Class.new(parent_class) do
        include Test::AutoInject[:view]
      end
    end

    specify "injected dependency matching the module's keyword is preserved" do
      instance = child_class.new
      expect(instance.one).to eq "dep 1"
      expect(instance.view).to eq "dep view"
    end
  end

  describe "module uses a required keyword" do
    let(:keyword_module) do
      Module.new do
        def initialize(view:, **kwargs)
          @view = view
          super(**kwargs)
        end
      end
    end

    let(:parent_class) do
      mod = keyword_module
      Class.new do
        include mod
        include Test::AutoInject[:one]
      end
    end

    let(:child_class) do
      Class.new(parent_class) do
        include Test::AutoInject[:view]
      end
    end

    specify "injected dependency matching the module's required keyword is preserved" do
      instance = child_class.new
      expect(instance.view).to eq "dep view"
    end
  end
end
