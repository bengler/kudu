Dir.mkdir('log') unless File.exist?('log')

environment = (ENV['RACK_ENV'] || "development").to_s.downcase

filename = "log/#{environment}.log"
logfile = File.new(filename, 'a+')
logfile.sync = true
Log = Logger.new(filename)
Log.level = environment == "production" ? Logger::WARN : Logger::DEBUG
#Log.datetime_format = "%Y-%m-%d %H:%M:%S.%L"
Log.formatter = lambda do |severity, datetime, progname, msg|
  "#{severity}: #{datetime}: #{msg}\n"
end

if environment == "development"
  STDERR.reopen(logfile)
  STDOUT.reopen(logfile)
end

KuduV1.use Rack::CommonLogger, logfile
Log.info "Logging is up. Writing to #{filename}"

