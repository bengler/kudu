require File.expand_path('config/site.rb') if File.exists?('config/site.rb')

require "bundler"
Bundler.require

LOGGER ||= Logger.new '/dev/null'

set :root, File.dirname(File.dirname(__FILE__))

$:.unshift('./lib')

Dir.glob('./lib/**/*.rb').each{ |lib| require lib }

$config = YAML::load(File.open("config/database.yml"))
environment = ENV['RACK_ENV'] || "development"

ActiveRecord::Base.establish_connection($config[environment])

Pebblebed.config do
  service 'checkpoint'
end
