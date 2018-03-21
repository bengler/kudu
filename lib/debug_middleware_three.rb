class DebugMiddlewareThree
  def initialize(app)
    @app = app
  end

  def call(env)
    testReq = Rack::Request.new(env)
    puts "DebugMiddlewareThree.session #{testReq.params['session']}"
    status, headers, response = @app.call(env)
    [status, headers, response]
  end
end
