require File.expand_path('config/site.rb') if File.exists?('config/site.rb')

require "bundler"
Bundler.require

LOGGER ||= Logger.new '/dev/null'

set :root, File.dirname(File.dirname(__FILE__))

$:.unshift('./lib')

Dir.glob('./lib/kudu/**/*.rb').each{ |lib| require lib }

$config = YAML::load(File.open("config/database.yml"))
environment = ENV['RACK_ENV'] || "development"

$memcached = Dalli::Client.new unless ENV['RACK_ENV'] == 'test'

unless ENV['RACK_ENV'] == 'test'
  require './lib/river_notifications'
  ActiveRecord::Base.add_observer RiverNotifications.instance
end

ActiveRecord::Base.establish_connection($config[environment])

Pebblebed.config do
  host ENV['RACK_ENV'] == 'production' ? 'apressen.o5.no' : nil
  scheme ENV['RACK_ENV'] == 'production' ? 'http' : nil
  service 'checkpoint'
end
