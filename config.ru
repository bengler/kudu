$:.unshift(File.dirname(__FILE__))

require 'config/environment'
require 'sinatra'
require 'api/v1'
require 'config/logging'
require 'rack/contrib'
require './lib/post_body_content_type_parser_local.rb'

set :environment, ENV['RACK_ENV'].to_sym
use Rack::CommonLogger

map "/api/kudu/v1" do
  use Rack::PostBodyContentTypeParserLocal
  use Rack::MethodOverride
  use Pebbles::Cors
  run KuduV1
end
