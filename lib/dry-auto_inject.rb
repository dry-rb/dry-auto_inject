# frozen_string_literal: true

require "dry/auto_inject"

module RuboCop
  module DryAutoInject
    autoload :Plugin, "rubocop/dry_auto_inject/plugin"
  end
end
