# frozen_string_literal: true

module Dry
  module AutoInject
    Error                    = Class.new(StandardError)
    DuplicateDependencyError = Class.new(Error)
    DependencyNameInvalid    = Class.new(Error)
  end
end
