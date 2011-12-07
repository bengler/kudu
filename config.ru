$:.unshift(File.dirname(__FILE__))

require 'config/environment'
require 'rack/contrib'

ENV['RACK_ENV'] ||= ENV['RAILS_ENV']
ENV['RACK_ENV'] ||= 'development'

set :environment, ENV['RACK_ENV'].to_sym

require 'config/logging'
require 'api/v1'

map "/api/kudu/v1" do
  use Rack::PostBodyContentTypeParser
  use Rack::MethodOverride
  run KuduV1
end

map '/ping' do
  run lambda { |env| [200, {"Content-Type" => "application/json"}, [{name: "checkpoint"}.to_json]] }
end
