# frozen_string_literal: true

require "rails_helper"

base_url = "/api/v1/user"

RSpec.describe base_url, type: :request do
  include_context :api_v1_request_spec

  describe "/" do
    context "not logged in" do
      it "responds" do
        get base_url, headers: json_headers
        expect(response.code).to eq("401")
        expect(json_result["error"]).to match(/login/i)
      end
    end

    context "a location" do
      let(:target) do
        {
          info: "nothing here"
        }
      end
      it "responds" do
        get base_url, headers: authorization_headers
        expect(json_result["current_user"]).to eq target.as_json
        expect(response.code).to eq("200")
      end
    end
  end
end
