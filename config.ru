$:.unshift(File.dirname(__FILE__))

require 'config/environment'
require 'sinatra'
require 'api/v1'
require 'config/logging'
require 'rack/contrib'
require './lib/debug_middleware_one.rb'
require './lib/debug_middleware_two.rb'
require './lib/post_body_content_type_parser_local.rb'

set :environment, ENV['RACK_ENV'].to_sym
use Rack::CommonLogger

map "/api/kudu/v1" do
  use DebugMiddlewareOne
  use Rack::PostBodyContentTypeParserLocal
  use DebugMiddlewareTwo
  use Rack::MethodOverride
  use Pebbles::Cors
  run KuduV1
end
