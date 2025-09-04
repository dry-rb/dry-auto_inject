# frozen_string_literal: true

require_relative "support/coverage"

begin
  require "byebug"
rescue LoadError; end

require_relative "support/rspec"

require "dry-auto_inject"

Dir.glob(Pathname.new(__dir__).join("support", "**", "*.rb")).each do |file|
  require_relative file
end

module Test
  def self.remove_constants
    constants.each(&method(:remove_const))
  end
end

RSpec.configure do |config|
  config.after do
    Test.remove_constants
  end
end
