source 'http://rubygems.org'

gem 'sinatra'
gem 'sinatra-activerecord'
gem 'activerecord', :require => 'active_record'
gem 'yajl-ruby'
gem 'pg'
gem 'logger'
gem 'pebbles', :git => 'git@github.com:benglerpebbles/pebblebed.git'
gem 'rabl'

group :development, :test do
  gem 'rake'
  gem 'bengler_test_helper',  :git => "git@github.com:origo/bengler_test_helper.git"
  gem 'simplecov'
  gem 'rspec'
  gem 'rack-test'
  gem 'rack-streaming-proxy', :git => 'https://github.com/origo/rack-streaming-proxy'
end

group :deployment do
  gem 'unicorn', '~> 4.1.1'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
end
