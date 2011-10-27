require "bundler"
Bundler.require

set :root, File.dirname(File.dirname(__FILE__))

Dir.glob('./lib/**/*.rb').each{ |lib| require lib }

$config = YAML::load(File.open("config/database.yml"))
environment = ENV['RACK_ENV'] || "development"

Tire::Model::Search.index_prefix  "kudu_#{environment.to_s.downcase}"

ActiveRecord::Base.establish_connection($config[environment])
