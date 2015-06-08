source 'https://rubygems.org'

gem 'sinatra', '~> 1.4.2'
gem 'sinatra-contrib', '~> 1.4.0'
gem 'sinatra-activerecord', '~> 1.2.2'
gem 'rack-contrib', :git => 'https://github.com/rack/rack-contrib'
gem 'activerecord', '~> 3.2.13', :require => 'active_record'
gem 'yajl-ruby', '~> 1.2.1'
gem 'pg', '~> 0.15.1'
gem 'curb', '~> 0.8.8'
gem 'json', '~> 1.8.3'
gem 'logger', '~> 1.2.3'
gem 'pebblebed', '~> 0.2.1'
gem 'pebbles-cors', :git => "https://github.com/bengler/pebbles-cors"
gem 'pebbles-path', '~> 0.0.3'
gem 'pebbles-uid', '~> 0.0.22'
gem 'dalli', '~> 2.6.4'
gem 'petroglyph', '~> 0.0.3'
gem 'thor', :require => false

gem 'rack-protection', '~> 1.5.3'

group :development, :test do
  gem 'bengler_test_helper', :git => "https://github.com/bengler/bengler_test_helper", :require => false
  gem 'rake', '~> 10.0.4'
  gem 'simplecov', '~> 0.7.1'
  gem 'rspec', '~> 2.8'
  gem 'rack-test', '~> 0.6.2'
end

group :production do
  gem 'airbrake', '~> 3.1.4', :require => false
  gem 'unicorn', '~> 4.8.3'
end
