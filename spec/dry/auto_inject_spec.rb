RSpec.describe Dry::AutoInject do
  def assert_valid_object(object)
    expect(object.one).to be(1)
    expect(object.two).to be(2)
    expect(object.three).to be(3)
  end

  before do
    module Test
      AutoInject = Dry::AutoInject({ one: 1, two: 2, 'namespace.three' => 3 })
    end
  end

  let(:child_class) do
    Class.new(parent_class) do
      attr_reader :foo

      def initialize(*args)
        @foo = 'bar'
        super
      end
    end
  end

  let(:grand_child_class) do
    Class.new(child_class)
  end

  context 'with positioned args' do
    let(:parent_class) do
      Class.new do
        include Test::AutoInject[:one, :two, 'namespace.three']

        def self.inherited(other)
          super
        end
      end
    end

    let(:test_args) do
      [
        [], [1, 2, 3], [nil, 2, 3], [1, nil, 3], [1, 2, nil], [nil, nil, 3],
        [1, nil, nil], [1, nil, 3]
      ]
    end

    it 'works' do
      test_args.each do |args|
        assert_valid_object(parent_class.new(*args))
        assert_valid_object(child_class.new(*args))
        assert_valid_object(grand_child_class.new(*args))
      end

      expect(grand_child_class.new(1, 2, 3).foo).to eql('bar')
    end

    context 'autoinject in a subclass' do
      let(:child_class) do
        Class.new(parent_class) do
          include Test::AutoInject[:one, :two, 'namespace.three']
        end
      end

      context 'superclass initialize accepts fixed arguments' do
        let(:parent_class) do
          Class.new do
            attr_reader :first

            def initialize(first)
              @first = first
            end
          end
        end

        it 'works' do
          test_args.each do |args|
            child_instance = child_class.new(*args)

            assert_valid_object(child_instance)
            expect(child_instance.first).to eq 1
          end
        end
      end

      context 'superclass initialize has matching signature' do
        let(:parent_class) do
          Class.new do
            attr_reader :args

            def initialize(*args)
              @args = args
            end
          end
        end

        it 'works' do
          test_args.each do |args|
            child_instance = child_class.new(*args)

            assert_valid_object(child_instance)
            expect(child_instance.args).to eq [1,2,3]
          end
        end
      end

      context 'superclass initialize accepts variable arguments' do
        let(:parent_class) do
          Class.new do
            attr_reader :first
            attr_reader :middle
            attr_reader :last

            def initialize(first, *middle, last)
              @first = first
              @middle = middle
              @last = last
            end
          end
        end

        it 'works' do
          test_args.each do |args|
            child_instance = child_class.new(*args)

            assert_valid_object(child_instance)
            expect(child_instance.first).to eq 1
            expect(child_instance.middle).to eq [2]
            expect(child_instance.last).to eq 3
          end
        end
      end

      context 'superclass initialize accepts no arguments' do
        let(:parent_class) do
          Class.new do
          end
        end

        it 'works' do
          test_args.each do |args|
            assert_valid_object(child_class.new(*args))
          end
        end
      end
    end
  end

  context 'with hash arg' do
    let(:parent_class) do
      Class.new do
        include Test::AutoInject.hash[:one, :two, 'namespace.three']

        attr_reader :other

        def self.inherited(other)
          super
        end

        def initialize(args)
          super
          @other = args[:other]
        end
      end
    end

    let(:test_args) do
      [
        {}, { one: 1, two: 2, three: 3 }, { two: 2, three: 3 },
        { one: 1, three: 3 }, { one: 1, two: 2 }, { three: 3 },
        { one: 1 }, { one: 1, three: 3 }
      ]
    end

    it 'works' do
      test_args.each do |args|
        assert_valid_object(parent_class.new(args))
        assert_valid_object(child_class.new(args))
        assert_valid_object(grand_child_class.new(args))
      end

      expect(parent_class.new(other: true).other).to be(true)
      expect(grand_child_class.new(one: 1, two: 2, three: 3).foo).to eql('bar')
    end
  end

  context 'with keyword args' do
    let(:parent_class) do
      Class.new do
        include Test::AutoInject.kwargs[:one, :two, 'namespace.three']

        attr_reader :other

        def initialize(other: nil, **args)
          super(**args)
          @other = other
        end
      end
    end

    let(:child_class) do
      Class.new(parent_class) do
        attr_reader :foo

        def initialize(**args)
          super
          @foo = 'bar'
        end
      end
    end

    let(:grand_child_class) do
      Class.new(child_class)
    end

    let(:test_args) do
      [
        {}, { one: 1, two: 2, three: 3 }, { two: 2, three: 3 },
        { one: 1, three: 3 }, { one: 1, two: 2 }, { three: 3 },
        { one: 1 }, { one: 1, three: 3 }
      ]
    end

    it 'works' do
      test_args.each do |args|
        assert_valid_object(parent_class.new(**args))
        assert_valid_object(child_class.new(**args))
        assert_valid_object(grand_child_class.new(**args))
      end

      expect(parent_class.new(other: true).other).to be(true)
      expect(grand_child_class.new(one: 1, two: 2, three: 3).foo).to eql('bar')
    end
  end
end
