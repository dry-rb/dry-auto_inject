# frozen_string_literal: true

RSpec.describe 'args / super #initialize method' do
  before do
    module Test
      AutoInject = Dry::AutoInject(one: 'dep 1')
    end
  end

  describe 'super #initialize using on dependencies set in the child class' do
    let(:child_class) {
      Class.new(parent_class) do
        include Test::AutoInject.args[:one]
      end
    }

    context 'super #initialize without parameters' do
      let(:parent_class) {
        Class.new do
          attr_reader :excited_one

          def initialize
            @excited_one = "#{one}!"
          end
        end
      }

      it 'sets the dependencies in the generated #initialize before calling super' do
        expect(child_class.new.excited_one).to eq 'dep 1!'
      end
    end

    context 'super #initiailze with parameters' do
      let(:parent_class) {
        Class.new do
          attr_reader :excited_one

          def initialize(one)
            @excited_one = "#{one}!"
          end
        end
      }

      it 'sets the dependenceies in the generated #initialize before caling super' do
        expect(child_class.new.excited_one).to eq 'dep 1!'
      end
    end
  end
end
