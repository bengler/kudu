source 'http://rubygems.org'

gem 'sinatra'
gem 'sinatra-activerecord'
gem 'activerecord', :require => 'active_record'
gem 'yajl-ruby'
gem 'pg'
gem 'tire', '~> 0.3.4'
gem 'logger'

group :development, :test do
  gem 'simplecov'
  gem 'rspec'
  gem 'rack-test'
end

group :deployment do
  gem 'unicorn', '~> 4.1.1'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
end
