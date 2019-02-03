# frozen_string_literal: true

require "grape_logging"

module GrapeLogging::Loggers
  class RegistrarLogger < GrapeLogging::Loggers::Base
    def parameters(request, _)
      { remote_ip: request.env["HTTP_CF_CONNECTING_IP"], format: "json" }
    end
  end
end

class API::Base < Grape::API
  content_type :json, "application/json"
  format :json
  default_error_formatter :json

  # Rescue and respond with a reasonable error message
  rescue_from :all do |e|
    API::Base.respond_to_error(e)
  end

  use GrapeLogging::Middleware::RequestLogger,
      instrumentation_key: "grape_key",
      include: [GrapeLogging::Loggers::RegistrarLogger.new,
                GrapeLogging::Loggers::FilterParameters.new]

  mount API::V1::RootV1

  def self.respond_to_error(e)
    logger.error e unless Rails.env.test? # Breaks tests...
    eclass = e.class.to_s
    opts = { error: e.message }
    opts[:trace] = e.backtrace[0, 10] unless Rails.env.production?
    Rack::Response.new(opts.to_json, status_code_for(e, eclass), {
                         "Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*",
                         "Access-Control-Request-Method" => "*"
                       }).finish
  end

  def self.status_code_for(error, eclass)
    if (eclass =~ /RecordNotFound/) || (error.message =~ /unable to find/i)
      404
    else
      (error.respond_to? :status) && error.status || 500
    end
  end
end
