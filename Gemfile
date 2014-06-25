source 'https://rubygems.org'

gem 'sinatra'
gem 'sinatra-contrib'
gem 'sinatra-activerecord'
gem 'rack-contrib', :git => 'https://github.com/rack/rack-contrib'
gem 'activerecord', '~> 3.2.13', :require => 'active_record'
gem 'yajl-ruby'
gem 'pg'
gem 'logger'
gem 'pebblebed', '~> 0.2.1'
gem 'pebbles-cors', :git => "https://github.com/bengler/pebbles-cors"
gem 'pebbles-path'
gem 'pebbles-uid'
gem 'dalli'
gem 'petroglyph'
gem 'thor', :require => false

gem 'rack-protection', '~> 1.5.3'

group :development, :test do
  gem 'bengler_test_helper', :git => "https://github.com/bengler/bengler_test_helper", :require => false
  gem 'rake'
  gem 'simplecov'
  gem 'rspec', '~> 2.8'
  gem 'rack-test'
end

group :production do
  gem 'airbrake', '~> 3.1.4', :require => false
  gem 'unicorn'
end
