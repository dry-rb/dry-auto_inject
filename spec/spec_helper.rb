if RUBY_ENGINE == 'ruby' && RUBY_VERSION >= '2.3'
  require 'simplecov'
  SimpleCov.start
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
