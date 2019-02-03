# frozen_string_literal: true

require "rails_helper"

base_url = "/api/v1/status"

RSpec.describe base_url, type: :request do
  include_context :api_v1_request_spec

  describe "/" do
    context "not logged in" do
      it "responds" do
        get base_url, headers: json_headers
        expect(response.code).to eq("200")
        expect(json_result["current"]).to eq "live"
      end
    end
  end
end
