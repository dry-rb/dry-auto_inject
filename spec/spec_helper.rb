$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'dry-auto_inject'

begin
  require 'byebug'
rescue LoadError; end

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
