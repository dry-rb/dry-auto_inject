# frozen_string_literal: true

require 'dry-container'

module Dry
  module AutoInject
    class Strategies
      extend Dry::Container::Mixin

      # @api public
      def self.register_default(name, strategy)
        register name, strategy
        register :default, strategy
      end
    end
  end
end

require 'dry/auto_inject/strategies/args'
require 'dry/auto_inject/strategies/hash'
require 'dry/auto_inject/strategies/kwargs'
