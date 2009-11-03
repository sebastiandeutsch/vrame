require 'rubygems'
require 'spork'

ENV["RAILS_ENV"] ||= 'test'

Spork.prefork do
  
  require File.dirname(__FILE__) + "/../../../../config/environment.rb"
  require 'spec/autorun'
  require 'spec/rails'  
  
  Spec::Runner.configure do |config|
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    config.fixture_path = File.join(File.dirname(__FILE__), 'fixtures/')
  end
  
end

Spork.each_run do
  # This code will be run each time you run your specs.
  
  
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
