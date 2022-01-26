# frozen_string_literal: true

require 'dry/auto_inject/strategies/base'
require 'dry/auto_inject/dependency_map'

module Dry
  module AutoInject
    class Strategies
      class Constructor < Base
        # @api private
        def included(klass)
          define_readers

          define_new
          define_initialize(klass)

          super
        end

        private

        def define_readers
          instance_mod.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            attr_reader #{dependency_map.names.map { |name| ":#{name}" }.join(', ')}
          RUBY
          self
        end

        def define_new
          raise NotImplementedError, 'must be implemented by a subclass'
        end

        def define_initialize(klass)
          raise NotImplementedError, 'must be implemented by a subclass'
        end
      end
    end
  end
end
