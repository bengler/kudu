source 'https://rubygems.org'


gem 'sinatra', '~> 2.0.1', require: 'sinatra/base'
gem 'sinatra-contrib', '~> 2.0.1'
gem 'sinatra-activerecord', '~> 2.0.13'
gem 'activerecord', '= 3.2.22', :require => 'active_record'
gem 'yajl-ruby', '~> 1.2.1'
gem 'pg', '= 0.18.3'
gem 'curb', '~> 0.8.8'
gem 'json', '~> 1.8.3'
gem 'logger', '~> 1.2.3'
gem 'pebblebed', '~> 0.4.3'
gem 'pebbles-cors', :git => "https://github.com/bengler/pebbles-cors"
gem 'pebbles-path', '~> 0.0.3'
gem 'pebbles-uid', '~> 0.0.22'
gem 'dalli', '~> 2.6.4'
gem 'petroglyph', '~> 0.0.7'
gem 'thor', '~> 0.18.1', :require => false
gem 'rack', '~> 2.0.4'
gem 'rack-protection', '~> 2.0.1'
gem 'rack-contrib', '~> 2.0.1'

group :development, :test do
  gem 'bengler_test_helper', :git => "https://github.com/bengler/bengler_test_helper", :require => false
  gem 'rake', '= 10.4.2'
  gem 'simplecov', '~> 0.7.1'
  gem 'rspec', '~> 2.8'
  gem 'rack-test', '~> 0.6.2'
end

group :production do
  gem 'airbrake', '~> 3.1.4', :require => false
  gem 'unicorn', '~> 4.8.3'
end
