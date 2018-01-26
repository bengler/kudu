require File.expand_path('config/site.rb') if File.exists?('config/site.rb')

require "bundler"
Bundler.require

LOGGER ||= Logger.new '/dev/null'

$:.unshift('./lib')

Dir.glob('./lib/kudu/**/*.rb').each{ |lib| require lib }

$config = YAML::load(File.open("config/database.yml"))
ENV['RACK_ENV'] ||= "development"
environment = ENV['RACK_ENV']

$memcached = Dalli::Client.new unless environment == 'test'

unless environment == 'test'
  require './lib/river_notifications'
  ActiveRecord::Base.add_observer RiverNotifications.instance
end

ActiveRecord::Base.establish_connection($config[environment])

Pebblebed.config do
  host environment == 'production' ? 'apressen.o5.no' : nil
  scheme environment == 'production' ? 'http' : nil
  service 'checkpoint'
end
