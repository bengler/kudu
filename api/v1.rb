# encoding: utf-8
require "json"
require 'pebblebed/sinatra'
require 'sinatra/petroglyph'
require 'sinatra/reloader'

Dir.glob("#{File.dirname(__FILE__)}/v1/**/*.rb").each{ |file| require file }


class KuduV1 < Sinatra::Base
  set :root, "#{File.dirname(__FILE__)}/v1"
  set :protection, :except => :http_origin

  error_counter = 0
  non_error_counter = 0

  register Sinatra::Pebblebed

  error ActiveRecord::RecordNotFound do
    halt 404, "Record not found"
  end

  helpers do

    def airbrake_this(errorMessage)
      puts errorMessage
      if LOGGER.respond_to?:exception
        error = StandardError.new(errorMessage)
        LOGGER.exception(error)
      else
        LOGGER.error(errorMessage)
      end
    end

  end

  before do
    response.headers['Cache-Control'] = 'public, max-age=300'

    # If this service, for some reason lives behind a proxy that rewrites the Cache-Control headers into
    # "must-revalidate" (which IE9, and possibly other IEs, does not respect), these two headers should properly prevent
    # caching in IE (see http://support.microsoft.com/kb/234067)
    headers 'Pragma' => 'no-cache'
    headers 'Expires' => '-1'
    incoming_session = request.fullpath.split('session=')[1]
    reported_session = current_session
    if incoming_session && reported_session && (incoming_session != reported_session)
      error_counter += 1
      airbrake_this("[#{error_counter}/#{error_counter+non_error_counter}] Request and session differ: #{reported_session} versus #{incoming_session}")
    else
      non_error_counter += 1
      LOGGER.info("|===<#{request.fullpath}>===<#{current_session}>===|")
    end
    cache_control :private, :no_cache, :no_store, :must_revalidate
  end

end
