source 'https://rubygems.org'

gem 'sinatra'
gem 'sinatra-contrib'
gem 'sinatra-activerecord'
gem 'rack-contrib', :git => 'git://github.com/rack/rack-contrib.git'
gem 'activerecord', :require => 'active_record'
gem 'yajl-ruby'
gem 'pg'
gem 'logger'
gem 'pebblebed', '~> 0.0.41'
gem 'pebbles-cors', :git => "git@github.com:bengler/pebbles-cors"
gem 'pebbles-path'
gem 'pebbles-uid'
gem 'petroglyph'
gem 'bengler_test_helper', :git => "git://github.com/bengler/bengler_test_helper.git", :require => false
gem 'thor', :require => false

# Because of a bug in rack-protection (https://github.com/rkh/rack-protection/commit/a91810fa) that affects
# cors-requests we'll need to get rack-protection from github
# This can safely be changed to the official rubygems version '> 1.2.0' whenever it is released
gem 'rack-protection', :git => 'git://github.com/rkh/rack-protection.git'

group :development, :test do
  gem 'rake'
  gem 'simplecov'
  gem 'rspec', '~> 2.8'
  gem 'rack-test'
end

group :production do
  gem 'airbrake', '~> 3.1.4', :require => false
  gem 'unicorn', '~> 4.1.1'
end
