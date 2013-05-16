# encoding: utf-8
require "json"
require 'pebblebed/sinatra'
require 'sinatra/petroglyph'
require 'sinatra/reloader'

Dir.glob("#{File.dirname(__FILE__)}/v1/**/*.rb").each{ |file| require file }

class KuduV1 < Sinatra::Base
  set :root, "#{File.dirname(__FILE__)}/v1"
  set :protection, :except => :http_origin

  register Sinatra::Pebblebed

  before do
    response.headers['Cache-Control'] = 'public, max-age=300'
    headers 'Pragma' => 'no-cache'
    headers 'Expires' => '-1'
    cache_control :private, :no_cache, :no_store, :must_revalidate
  end

end
