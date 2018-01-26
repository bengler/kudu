$:.unshift(File.dirname(__FILE__))

# Hack Begin to preserve tasks in the Rake namespace
self.instance_eval do
  alias :namespace_pre_sinatra :namespace if self.respond_to?(:namespace, true)
end
require 'sinatra/namespace'
self.instance_eval do
  alias :namespace :namespace_pre_sinatra if self.respond_to?(:namespace_pre_sinatra, true)
end
# Hack End

require 'config/environment'
require 'sinatra/activerecord/rake'
require 'bengler_test_helper/tasks' if ['development', 'test'].include?(ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development')

task :environment do
  require 'config/environment'
end

namespace :db do
  desc "bootstrap db user, recreate, run migrations"
  task :bootstrap do
    name = "kudu"
    `createuser -sdR #{name}`
    `createdb -O #{name} #{name}_development`
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:test:prepare'].invoke
  end

  task :migrate => :environment

  desc "nuke db, recreate, run migrations"
  task :nuke do
    name = "kudu"
    `dropdb #{name}_development`
    `createdb -O #{name} #{name}_development`
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:test:prepare'].invoke
  end

  desc "add seed data to database"
  task :seed => :environment do
    require_relative './db/seeds'
  end
end
