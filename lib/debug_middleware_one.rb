class DebugMiddlewareOne
  def initialize(app)
    @app = app
  end

  def call(env)
    testReq = Rack::Request.new(env)
    LOGGER.info "DebugMiddlewareOne.session #{testReq.params['session']}"
    status, headers, response = @app.call(env)
    [status, headers, response]
  end
end
