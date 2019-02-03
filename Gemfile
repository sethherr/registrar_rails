# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.5.1"

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails", "~> 5.2.2"
# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
gem "pg_search" # Full text search - e.g. admin_search in user
# Use Puma as the app server
gem "puma", "~> 3.11"

# API stuff
gem "active_model_serializers", "~> 0.8.3" # Use active model serializers to serialize JSON. Use version 0.8 because it supports caching
gem "kaminari" # Pagination
gem "grape", "~> 1.0.3" # DSL for APIs
gem "grape_logging" # Ensuring we get logs from Grape
gem "grape-swagger" # Swagger spec for Grape
gem "api-pagination" # Paginate the APIs
gem "rack-cors", require: "rack/cors" # Allow CORS access

# Redis, redis requirements
gem "hiredis" # Redis driver for MRI
gem "redis" # Redis itself
gem "readthis" # caching (using redis)
gem "sidekiq" # Background job processing (with redis)
gem "sinatra" # Used for sidekiq web
gem "sidekiq-failures" # Show sidekiq failures

# Users
gem "devise"
gem "omniauth", "~> 1.6.1" # sign on with other services
gem "omniauth-bike-index"

# Useful packages
gem "money-rails"
gem "carrierwave" # uploading photos
gem "fog-aws" # Store files on AWS
gem "mini_magick" # a smaller implementation of rmagick, required for rqrcode

# Frontend things
gem "uglifier", ">= 1.3.0" # Use Uglifier as compressor for JavaScript assets
gem "webpacker" # Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "hamlit" # Faster haml templates
gem "premailer-rails" # Inline styles for email
gem "sass-rails", "~> 5.0" # Use SCSS for stylesheets - necessary for email styles

group :production do
  # Make logging - more useful and ingestible
  gem "lograge" # Structure log data, put it in single lines to improve the functionality
  gem "logstash-event" # Use logstash format for logging data
  gem "honeybadger", "~> 3.1" # Error monitoring
end

group :development, :test do
  gem "foreman" # Process runner for local work
  gem "rspec-rails" # Test framework
  gem "factory_bot_rails" # mocking/stubbing
end

group :development do
  # Access an interactive console on exception pages or by calling "console" anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5", "< 3.2"
end

group :test do
  gem "guard", "~> 2.13.0", require: false
  gem "guard-rspec", "~> 4.6.4", require: false
  gem "guard-rubocop", require: false
  gem "rspec_junit_formatter" # For circle ci
  gem "rails-controller-testing" # Assert testing views
  gem "vcr" # Stub external HTTP requests
  gem "webmock" # mocking for VCR
end

# Performance Stuff
gem "fast_blank" # high performance replacement String#blank? a method that is called quite frequently in ActiveRecord
gem "flamegraph", require: false
gem "stackprof", require: false # Required by flamegraph
gem "rack-mini-profiler", require: false # If you can't see it you can't make it better
gem "bootsnap", ">= 1.1.0", require: false # Reduces boot times through caching; required in config/boot.rb