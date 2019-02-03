# frozen_string_literal: true

class DocumentationController < ApplicationController
  def index
    redirect_to controller: :documentation, action: :api_v1
  end

  def api_v1
    @swagger_path = "/api/v1/swagger_doc"
    render layout: false
  end
end
