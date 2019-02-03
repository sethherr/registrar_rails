custom_web: bundle exec puma -e $RACK_ENV -b unix:///tmp/web_server.sock --pidfile /tmp/web_server.pid -d
worker_critical: bundle exec sidekiq -q default -q mailers
