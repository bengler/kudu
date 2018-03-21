class DebugMiddlewareOne
  def initialize(app)
    @app = app
  end

  def call(env)
    testReq = Rack::Request.new(env)
    puts "DebugMiddlewareOne.session #{testReq.params['session']}"
    status, headers, response = @app.call(env)
    [status, headers, response]
  end
end
