# frozen_string_literal: true

RSpec.describe "kwargs / inheritance / instance variables set before #initialize" do
  before do
    module Test
      AutoInject = Dry::AutoInject(configuration: "configuration", another_dep: "another_dep")
    end
  end

  let(:framework_class) {
    Class.new do
      def self.new(configuration:, **args)
        allocate.tap do |obj|
          obj.instance_variable_set :@configuration, configuration
          obj.send :initialize, **args
        end
      end
    end
  }

  let(:parent_class) {
    Class.new(framework_class) do
      include Test::AutoInject.hash[:configuration]
    end
  }

  let(:child_class) {
    Class.new(parent_class) do
      include Test::AutoInject.hash[:another_dep]
    end

  }

  it "does not assign nil value from missing dependency arg to its instance variable if it is already defined" do
    child = child_class.new
    expect(child.configuration).to eq "configuration"
    expect(child.another_dep).to eq "another_dep"
  end

  it "does assign an explicitly provided non-nil dependency to iits instance variable, even if it is already defined" do
    child = child_class.new(configuration: "child configuration")
    expect(child.configuration).to eq "child configuration"
    expect(child.another_dep).to eq "another_dep"
  end
end
