# frozen_string_literal: true

class ErrorsController < ApplicationController
  respond_to :html, :json
  before_action :set_permitted_format

  def bad_request
    render status: 400
  end

  def unauthorized
    render status: 401
  end

  def not_found
    render status: 404
  end

  def unprocessable_entity
    render status: 422
  end

  def server_error
    render layout: false, status: 500
  end

  private

  def set_permitted_format
    request.format = "html" unless request.format == "json"
  end
end
