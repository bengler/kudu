listen 13100

worker_processes 4

pid "/srv/kudu/shared/pids/unicorn.pid"
stderr_path "/srv/kudu/shared/log/unicorn.log"
stdout_path "/srv/kudu/shared/log/unicorn.log"
working_directory "/srv/kudu/current"

user 'kudu', 'kudu'

timeout 60

# combine REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
#preload_app true
#GC.respond_to?(:copy_on_write_friendly=) and
#  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
