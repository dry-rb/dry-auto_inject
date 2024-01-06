# frozen_string_literal: true

RSpec.describe "allow condition" do
  describe "allow" do
    before do
      module Test
        AutoInject = Dry::AutoInject({one: 1, two: 2})
        OnlyOneInject = AutoInject.allow(/one/)
      end
    end

    subject(:instance) { including_class.new }

    context 'when user injects allowed keys' do
      let(:including_class) do
        Class.new do
          include Test::OnlyOneInject[:one]
        end
      end

      it { expect(instance.one).to eq 1 }
    end

    context 'when user injects all keys' do
      let(:including_class) do
        Class.new do
          include Test::OnlyOneInject[:one, :two]
        end
      end

      it { expect { instance }.to raise_error }
    end
  end
end
