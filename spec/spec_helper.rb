if RUBY_ENGINE == "ruby"
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start

  require "simplecov"
  SimpleCov.start do
    add_filter "/spec/"
  end
end

begin
  require 'byebug'
rescue LoadError; end

require 'dry-auto_inject'

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
