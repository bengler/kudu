$:.unshift(File.dirname(__FILE__))

require 'config/environment'
require 'sinatra'
require 'api/v1'
require 'config/logging'
require 'rack/contrib'
require './lib/debug_middleware_one.rb'
require './lib/debug_middleware_two.rb'
require './lib/debug_middleware_three.rb'
require './lib/debug_middleware_four.rb'

set :environment, ENV['RACK_ENV'].to_sym
use Rack::CommonLogger

map "/api/kudu/v1" do
  use DebugMiddlewareOne
  use Rack::PostBodyContentTypeParser
  use DebugMiddlewareTwo
  use Rack::MethodOverride
  use DebugMiddlewareThree
  use Pebbles::Cors
  use DebugMiddlewareFour
  run KuduV1
end
