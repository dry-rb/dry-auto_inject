# frozen_string_literal: true

RSpec.describe 'kwargs / inheritance / parent class also auto-injecting' do
  before do
    module Test
      AutoInject = Dry::AutoInject(one: 'dep 1', two: 'dep 2')
    end
  end

  describe 'differing injections' do
    let(:parent_class) {
      Class.new do
        include Test::AutoInject[:one]
      end
    }

    let(:child_class) {
      Class.new(parent_class) do
        include Test::AutoInject[:two]
      end
    }

    specify 'auto-injections from parent class are available in child class' do
      child = child_class.new
      expect(child.one).to eq 'dep 1'
      expect(child.two).to eq 'dep 2'
    end
  end

  describe 'matching overlapping injections' do
    let(:parent_class) {
      Class.new do
        include Test::AutoInject[:one, :two]
      end
    }

    let(:child_class) {
      Class.new(parent_class) do
        include Test::AutoInject[:two]
      end
    }

    specify "the child class' injection is kept" do
      child = child_class.new
      expect(child.one).to eq 'dep 1'
      expect(child.two).to eq 'dep 2'
    end
  end

  describe 'differing overlapping injections' do
    let(:parent_class) {
      Class.new do
        include Test::AutoInject[:one, :two]
      end
    }

    let(:child_class) {
      Class.new(parent_class) do
        include Test::AutoInject[one: :two]
      end
    }

    specify "the child class' injection is kept" do
      child = child_class.new
      expect(child.one).to eq 'dep 2'
      expect(child.two).to eq 'dep 2'
    end
  end
end
