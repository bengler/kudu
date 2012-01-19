require "bundler"
Bundler.require

set :root, File.dirname(File.dirname(__FILE__))

Dir.glob('./lib/**/*.rb').each{ |lib| require lib }

$config = YAML::load(File.open("config/database.yml"))
environment = ENV['RACK_ENV'] || "development"


Hupper.on_initialize do
  ActiveRecord::Base.establish_connection($config[environment])
end

Hupper.on_release do
  ActiveRecord::Base.connection.disconnect!
end

Pebblebed.config do
  service 'checkpoint'
end
