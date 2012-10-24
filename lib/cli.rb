require 'logger'

module Kudu

  class CLI < Thor

    LOGGER = Logger.new(STDOUT) unless defined?(LOGGER)

    desc "recalculate", "Recalculate all scores from raw ack data"
    def recalculate
      require_relative '../config/environment'
      ActiveRecord::Base.logger.level = Logger::WARN
      Score.calculate_all
    end
  end
end

