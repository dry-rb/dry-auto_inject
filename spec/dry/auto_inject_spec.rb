RSpec.describe Dry::AutoInject do
  def assert_valid_object(object)
    expect(object.one).to eq 1
    expect(object.two).to eq 2
    expect(object.three).to eq 3
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
        include Test::AutoInject.args[:one, :two, 'namespace.three']
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

    it 'raises an argument error when non-specific args are passed to the initializer' do
      expect { parent_class.new(nil, nil, nil, 'unexpected') }.to raise_error ArgumentError
    end

    context 'aliased dependencies' do
      def assert_valid_object(object)
        expect(object.one).to eq 1
        expect(object.two).to eq 2
        expect(object.last).to eq 3
      end

      let(:parent_class) do
        Class.new do
          include Test::AutoInject.args[:one, :two, last: 'namespace.three']
        end
      end

      it 'works' do
        test_args.each do |args|
          assert_valid_object(parent_class.new(*args))
          assert_valid_object(child_class.new(*args))
          assert_valid_object(grand_child_class.new(*args))
        end
      end
    end

    context 'autoinject in a subclass' do
      let(:child_class) do
        Class.new(parent_class) do
          include Test::AutoInject.args[:one, :two, 'namespace.three']
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

    context 'aliased dependencies' do
      def assert_valid_object(object)
        expect(object.one).to eq 1
        expect(object.two).to eq 2
        expect(object.last).to eq 3
      end

      let(:parent_class) do
        Class.new do
          include Test::AutoInject.hash[:one, :two, last: 'namespace.three']
        end
      end

      it 'works' do
        test_args.each do |args|
          assert_valid_object(parent_class.new(args))
          assert_valid_object(child_class.new(args))
          assert_valid_object(grand_child_class.new(args))
        end
      end
    end

    context 'autoinject in a subclass' do
      let(:child_class) do
        Class.new(parent_class) do
          include Test::AutoInject.hash[:one, :two, 'namespace.three']
        end
      end

      context 'superclass initialize accepts option hash' do
        let(:parent_class) do
          Class.new do
            attr_reader :first

            def initialize(options)
              @first = options[:one]
            end
          end
        end

        it 'works' do
          test_args.each do |args|
            child_instance = child_class.new(args)

            assert_valid_object(child_instance)
            expect(child_instance.first).to eq 1
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
            assert_valid_object(child_class.new(args))
          end
        end
      end
    end

    context 'multiple autoinject' do
      let(:klass) do
        Class.new do
          include Test::AutoInject.hash[:one]
          include Test::AutoInject.hash[:two]
        end
      end

      it 'works' do
        instance = klass.new

        expect(instance.one).to eq 1
        expect(instance.two).to eq 2
      end
    end

    context 'autoinject in class and included module' do
      let(:klasses) do
        mixin = Module.new do
          def self.included(klass)
            klass.send :include, Test::AutoInject.hash[:two]
          end
        end

        k1 = Class.new do
          include Test::AutoInject.hash[:one]
          include mixin
        end

        k2 = Class.new do
          include mixin
          include Test::AutoInject.hash[:one]
        end

        [k1, k2]
      end

      it 'works regardless inclusion order' do
        klasses.each do |klass|
          instance = klass.new

          expect(instance.one).to eq 1
          expect(instance.two).to eq 2
        end
      end
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

    it 'raise an argument error when non-specified keywords are passed to initializer' do
      expect { parent_class.new(unexpected: 'foo') }.to raise_error ArgumentError
    end

    context 'aliased dependencies' do
      let(:test_args) do
        [
          {}, { one: 1, two: 2, last: 3 }, { two: 2, last: 3 },
          { one: 1, last: 3 }, { one: 1, two: 2 }, { last: 3 },
          { one: 1 }, { one: 1, last: 3 }
        ]
      end

      def assert_valid_object(object)
        expect(object.one).to eq 1
        expect(object.two).to eq 2
        expect(object.last).to eq 3
      end

      let(:parent_class) do
        Class.new do
          include Test::AutoInject.kwargs[:one, :two, last: 'namespace.three']
        end
      end

      it 'works' do
        test_args.each do |args|
          assert_valid_object(parent_class.new(**args))
          assert_valid_object(child_class.new(**args))
          assert_valid_object(grand_child_class.new(**args))
        end
      end
    end

    context 'autoinject in a subclass' do
      let(:child_class) do
        Class.new(parent_class) do
          include Test::AutoInject.kwargs[:one, :two, 'namespace.three']
        end
      end

      context 'superclass initialize accepts keyword args' do
        let(:parent_class) do
          Class.new do
            attr_reader :first

            def initialize(one: nil, **args)
              @first = one
            end
          end
        end

        it 'works' do
          test_args.each do |args|
            child_instance = child_class.new(**args)

            assert_valid_object(child_instance)
            expect(child_instance.first).to eq 1
          end
        end
      end

      context 'superclass initialize accepts keywords args outside the injected dependencies list' do
        let(:parent_class) do
          Class.new do
            attr_reader :other

            def initialize(other: nil)
              @other = other
            end
          end
        end

        it 'works' do
          test_args.each do |args|
            child_instance = child_class.new(other: 'other', **args)

            assert_valid_object(child_instance)
            expect(child_instance.other).to eq 'other'
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
            assert_valid_object(child_class.new(**args))
          end
        end
      end
    end

    context 'multiple autoinject' do
      let(:klass) do
        Class.new do
          include Test::AutoInject.kwargs[:one]
          include Test::AutoInject.kwargs[:two]
        end
      end

      it 'works' do
        instance = klass.new

        expect(instance.one).to eq 1
        expect(instance.two).to eq 2
      end
    end

    context 'autoinject in class and included module' do
      let(:klasses) do
        mixin = Module.new do
          def self.included(klass)
            klass.send :include, Test::AutoInject.kwargs[:two]
          end
        end

        k1 = Class.new do
          include Test::AutoInject.kwargs[:one]
          include mixin
        end

        k2 = Class.new do
          include mixin
          include Test::AutoInject.kwargs[:one]
        end

        [k1, k2]
      end

      it 'works regardless inclusion order' do
        klasses.each do |klass|
          instance = klass.new

          expect(instance.one).to eq 1
          expect(instance.two).to eq 2
        end
      end
    end
  end
end
