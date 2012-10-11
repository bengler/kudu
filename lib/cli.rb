require 'logger'

module Kudu

  class CLI < Thor

    LOGGER = Logger.new(STDOUT) unless defined?(LOGGER)

    desc "recalculate", "Recalculate all scores from raw ack data"
    def recalculate
      require_relative '../config/environment'
      LOGGER.info "Recalculating all scores..."
      Score.calculate_all
      LOGGER.info "Recalculations complete."
    end
  end
end

