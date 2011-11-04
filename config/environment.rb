require "bundler"
Bundler.require

set :root, File.dirname(File.dirname(__FILE__))

Dir.glob('./lib/**/*.rb').each{ |lib| require lib }

$config = YAML::load(File.open("config/database.yml"))
environment = ENV['RACK_ENV'] || "development"

ActiveRecord::Base.establish_connection($config[environment])

$redis_config = YAML::load(File.open("config/redis.yml"))
$redis = Redis.new($redis_config[environment])