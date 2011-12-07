require "bundler"
Bundler.require

set :root, File.dirname(File.dirname(__FILE__))

Dir.glob('./lib/**/*.rb').each{ |lib| require lib }

$config = YAML::load(File.open("config/database.yml"))
environment = ENV['RACK_ENV'] || "development"

ActiveRecord::Base.establish_connection($config[environment])

Pebblebed.config do
  service 'checkpoint'
end
