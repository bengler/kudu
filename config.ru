$:.unshift(File.dirname(__FILE__))

require 'config/environment'

ENV['RACK_ENV'] ||= ENV['RAILS_ENV']
ENV['RACK_ENV'] ||= 'development'

set :environment, ENV['RACK_ENV'].to_sym

api = lambda do |env|
  info = {:available_endpoints => ['/api/kudu/v1']}
  return [200, {"Content-Type" => "application/json"}, [info.to_json]]
end

test = lambda do |env|
  env_data = {"ENV['RACK_ENV']" => ENV['RACK_ENV']}
  return [200, {"Content-Type" => "application/json"}, [env_data.to_json]]
end

require 'api/v1'

require 'config/logging'

map "/" do
  run api
end

map '/test' do
  run test
end

map "/api/kudu/v1" do
  run KuduV1
end
