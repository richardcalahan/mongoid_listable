require 'mongoid'
require File.expand_path '../../lib/mongoid_listable', __FILE__
require 'rspec'

Dir["#{File.dirname(__FILE__)}/models/*.rb"].each { |file| require file }

Mongoid.configure do |config|
  config.connect_to 'mongoid_listable_test'
  Moped.logger = Logger.new $stdout
  Moped.logger.level = Logger::INFO
end

RSpec.configure do |config|
  config.before :suite do 
    Mongoid.purge!
    Mongoid::IdentityMap.clear
  end
end