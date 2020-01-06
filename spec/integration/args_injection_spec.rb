# frozen_string_literal: true

RSpec.describe "argument parameters" do
  describe "inheritance" do
    describe "module included with an initialize accepting anonymous splat and passing all args through to super (which accepts no args)" do
      before do
        module Test
          AutoInject = Dry::AutoInject({ one: 1 }).args

          module PassThroughInitializer
            attr_reader :module_var

            def initialize(*)
              super
              @module_var = "hi"
            end
          end
        end
      end

      let(:including_class) do
        Class.new do
          include Test::PassThroughInitializer
          include Test::AutoInject[:one]
        end
      end

      it "works" do
        instance = including_class.new

        expect(instance.one).to eq 1
        expect(instance.module_var).to eq "hi"
      end
    end
  end
end
