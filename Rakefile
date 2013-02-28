$:.unshift(File.dirname(__FILE__))

require "bundler"
Bundler.require

require 'sinatra/activerecord/rake'
require 'bengler_test_helper/tasks'

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
