module Dry
  class Injection < Module
    attr_reader :names

    attr_reader :container

    attr_reader :instance_mod

    attr_reader :ivars

    def initialize(names, container)
      @names = names
      @container = container
      @ivars = names.map(&:to_s).map { |s| s.split('.').last }.map(&:to_sym)
      @instance_mod = Module.new
      define_constructor
    end

    def included(klass)
      klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.new(*args)
          names = [#{names.map(&:inspect).join(', ')}]
          deps = names.map.with_index { |_, i| args[i] || container[names[i]] }
          super(*deps)
        end
      RUBY

      klass.instance_variable_set('@container', container)

      klass.class_eval do
        def self.container
          if superclass.respond_to?(:container)
            superclass.container
          else
            @container
          end
        end
      end

      klass.send(:include, instance_mod)

      super
    end

    def define_constructor
      instance_mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          attr_reader #{ivars.map { |name| ":#{name}" }.join(', ')}

          def initialize(*args)
            #{ivars.map.with_index { |name, i| "@#{name} = args[#{i}]" }.join("\n")}
          end
      RUBY
      self
    end
  end
end
