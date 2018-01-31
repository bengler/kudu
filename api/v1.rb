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

  error ActiveRecord::RecordNotFound do
    halt 404, "Record not found"
  end

  before do
    LOGGER.info("====BEFORE====\nParams: #{params.inspect}\n====BEFORE====\n")

    response.headers['Cache-Control'] = 'public, max-age=300'

    # If this service, for some reason lives behind a proxy that rewrites the Cache-Control headers into
    # "must-revalidate" (which IE9, and possibly other IEs, does not respect), these two headers should properly prevent
    # caching in IE (see http://support.microsoft.com/kb/234067)
    headers 'Pragma' => 'no-cache'
    headers 'Expires' => '-1'

    cache_control :private, :no_cache, :no_store, :must_revalidate
  end

end
