
# Extend Sinatra for debugging
module Sinatra
  module Paramstest
    module Helpers

      def output_params
        raise "output_params #{params}"
      end

    end

    def self.registered(app)
      app.helpers(Sinatra::Paramstest::Helpers)
    end
  end
end
