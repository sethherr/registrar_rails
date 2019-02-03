# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Swagger", type: :request do
  describe "api/v1" do
    it "responds with swagger_doc" do
      get "/api/v1/swagger_doc"
      expect(response.code).to eq("200")
      expect(json_result["paths"].count).to be > 0
    end
  end
end
