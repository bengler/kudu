begin
  require 'json'
rescue LoadError => e
  require 'json/pure'
end

module Rack

  # A Rack middleware for parsing POST/PUT body data when Content-Type is
  # not one of the standard supported types, like <tt>application/json</tt>.
  #
  # TODO: Find a better name.
  #
  class PostBodyContentTypeParserLocal

    # Constants
    #
    CONTENT_TYPE = 'CONTENT_TYPE'.freeze
    POST_BODY = 'rack.input'.freeze
    FORM_INPUT = 'rack.request.form_input'.freeze
    FORM_HASH = 'rack.request.form_hash'.freeze

    # Supported Content-Types
    #
    APPLICATION_JSON = 'application/json'.freeze

    def initialize(app)
      @app = app
    end

    def log_params(current_env, index, body = nil)
      tmpReq = Rack::Request.new(current_env)
      LOGGER.info "ParserSpy-#{index} request_method #{tmpReq.request_method}"
      LOGGER.info "ParserSpy-#{index} env.POST_BODY #{body.inspect}" if body
      LOGGER.info "ParserSpy-#{index} FORM_HASH #{current_env[FORM_HASH].inspect}"
      LOGGER.info "ParserSpy-#{index} params #{tmpReq.params.inspect}"
    end

    def call(env)
      current_request = Rack::Request.new(env)
      if current_request.media_type == APPLICATION_JSON && (body = env[POST_BODY].read).length != 0
        # if (current_request.post? || current_request.put? || current_request.patch?) && current_request.media_type == APPLICATION_JSON && (body = env[POST_BODY].read).length != 0
        log_params(env, 1, body)
        env[POST_BODY].rewind # somebody might try to read this stream
        log_params(env, 2)
        env.update(FORM_HASH => JSON.parse(body, :create_additions => false), FORM_INPUT => env[POST_BODY])
        log_params(env, 3)
      end
      @app.call(env)
    rescue JSON::ParserError
      bad_request('failed to parse body as JSON')
    end

    def bad_request(body = 'Bad Request')
      [ 400, { 'Content-Type' => 'text/plain', 'Content-Length' => body.size.to_s }, [body] ]
    end
  end
end
