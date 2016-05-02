require "dry/auto_inject/dependency_map"

RSpec.describe Dry::AutoInject::DependencyMap do
  subject(:dependency_map) { Dry::AutoInject::DependencyMap.new(*dependencies) }
  let(:dependencies) { ["namespace.one", "namespace.two"] }

  it "registers specified dependencies" do
    expect(dependency_map.dependencies).to eq({one: "namespace.one", two: "namespace.two"})
  end

  context "aliases" do
    let(:dependencies) { ["namespace.one", second: "namespace.two"] }

    it "registers dependencies with their specified aliases" do
      expect(dependency_map.dependencies).to eq({one: "namespace.one", second: "namespace.two"})
    end
  end

  context "aliases only" do
    let(:dependencies) { [first: "namespace.one", second: "namespace.two"] }

    it "registers dependencies with their specified aliases" do
      expect(dependency_map.dependencies).to eq({first: "namespace.one", second: "namespace.two"})
    end
  end

  context "duplicate identifiers" do
    let(:dependencies) { ["namespace.one", "namespace.one"] }

    it "raises an error" do
      expect { dependency_map }.to raise_error(Dry::AutoInject::DuplicateDependencyError)
    end
  end

  context "conflicts with automatically determined short names for identifiers" do
    let(:dependencies) { ["namespace.one", "another_namespace.one"] }

    it "raises an error" do
      expect { dependency_map }.to raise_error(Dry::AutoInject::DuplicateDependencyError)
    end
  end

  context "conflicts with provided aliases" do
    let(:dependencies) { ["namespace.one", one: "namespace.two"] }

    it "raises an error" do
      expect { dependency_map }.to raise_error(Dry::AutoInject::DuplicateDependencyError)
    end
  end
end
