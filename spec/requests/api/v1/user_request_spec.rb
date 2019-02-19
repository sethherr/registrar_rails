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

    context "logged in" do
      let(:target) do
        {
          name: user.display_name,
          authorizations: []
        }
      end
      it "responds" do
        get base_url, headers: authorization_headers
        expect(json_result["current_user"]).to eq target.as_json
        expect(response.code).to eq("200")
      end
      context "with Bike Index authorized" do
        let(:target_with_authorization) { target.merge(authorizations: ["bike_index"]) }
        let!(:user_integration) { FactoryBot.create(:user_integration_bike_index, user: user) }
        it "responds" do
          get base_url, headers: authorization_headers
          expect(json_result["current_user"]).to eq target_with_authorization.as_json
          expect(response.code).to eq("200")
        end
      end
    end
  end
end
