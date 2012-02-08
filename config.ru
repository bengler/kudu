$:.unshift(File.dirname(__FILE__))

require 'config/environment'
require 'api/v1'
require 'config/logging'
require 'rack/contrib'

ENV['RACK_ENV'] ||= 'development'
set :environment, ENV['RACK_ENV'].to_sym

use Rack::CommonLogger

Pingable.active_record_checks!

map "/api/kudu/v1/ping" do
  use Pingable::Handler, "kudu"
end

map "/api/kudu/v1" do
  use Rack::PostBodyContentTypeParser
  use Rack::MethodOverride
  run KuduV1
end
