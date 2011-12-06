$:.unshift(File.dirname(__FILE__))

require 'config/environment'
require 'sinatra/activerecord/rake'
require 'bengler_test_helper/tasks'

namespace :db do

  desc "bootstrap db user, recreate, run migrations"
  task :bootstrap do
    `createuser -sdR kudu`
    `createdb -O kudu kudu_development`
    Rake::Task['db:migrate'].invoke
  end

  task :migrate do
    Rake::Task["db:structure:dump"].invoke
  end

  desc "nuke db, recreate, run migrations"
  task :nuke do
    `dropdb kudu_development`
    `createdb -O kudu kudu_development`
    Rake::Task['db:migrate'].invoke
  end

  desc "add seed data to database"
  task :seed do
    require_relative './db/seeds'
  end
end
