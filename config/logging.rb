Log = O5.log
Dalli.logger = O5.log if defined?(Dalli)
ActiveRecord::Base.logger.level = Logger::WARN
