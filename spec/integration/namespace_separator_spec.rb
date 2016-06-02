RSpec.describe "Namespace separator" do
  context "when using a dry-container" do
    before do
      module ContainerWithStars
        extend Dry::Container::Mixin
      end
      ContainerWithStars.configure do |config|
        config.namespace_separator = '*'
      end
      ContainerWithStars.register(:one, -> { 1 })
      ContainerWithStars.register(:two, -> { 2 })
      ContainerWithStars.namespace('namespace') do
        register('three', -> { 3 })
      end

      module NamespacesWithDryContainer
        Inject = Dry::AutoInject(ContainerWithStars)
      end
    end

    let(:test_class) do
      Class.new do
        include NamespacesWithDryContainer::Inject[:one, :two, 'namespace*three']
      end
    end

    it 'uses the container namespace separator' do
      instance = test_class.new

      expect(instance.one).to eq 1
      expect(instance.two).to eq 2
      expect(instance.three).to eq 3
    end
  end

  context "when using an option to specify" do
    before do
      module NamespacesWithOption
        Inject = Dry::AutoInject(
          {one: 1, two: 2, 'namespace*three' => 3},
          {namespace_separator: '*'}
        )
      end
    end

    let(:test_class) do
      Class.new do
        include NamespacesWithOption::Inject[:one, :two, 'namespace*three']
      end
    end

    it 'uses the specified namespace separator' do
      instance = test_class.new

      expect(instance.one).to eq 1
      expect(instance.two).to eq 2
      expect(instance.three).to eq 3
    end
  end

  context "when unspecified" do
    before do
      module NamespacesWithDefault
        Inject = Dry::AutoInject({one: 1, two: 2, 'namespace.three' => 3})
      end
    end

    let(:test_class) do
      Class.new do
        include NamespacesWithDefault::Inject[:one, :two, 'namespace.three']
      end
    end

    it 'defaults to "." for a namespace separator' do
      instance = test_class.new

      expect(instance.one).to eq 1
      expect(instance.two).to eq 2
      expect(instance.three).to eq 3
    end
  end
end
