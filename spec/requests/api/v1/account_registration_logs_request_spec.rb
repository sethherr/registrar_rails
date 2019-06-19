# frozen_string_literal: true

require "rails_helper"

RSpec.describe "api/v1/account/registrations/{id}/logs", type: :request do
  include_context :api_v1_request_spec
  let(:base_url) { "/api/v1/account/registrations/#{registration.to_param}/logs" }

  describe "/" do
    let!(:registration) { FactoryBot.create(:registration) }
    context "not logged in" do
      it "responds" do
        get base_url, headers: json_headers
        expect(response.code).to eq("401")
        expect(json_result["error"]).to match(/login/i)
      end
    end
  end

  context "logged in" do
    describe "/" do
      let!(:registration) { FactoryBot.create(:registration_with_current_owner, user: user) }
      let(:registration_log_ownership) { registration.registration_logs.first }
      let(:registration_log_target) do
        {
          id: registration_log_ownership.to_param,
          created_at: registration_log_ownership.created_at.to_i,
          kind: "ownership",
          description: "initial ownership",
          authorizer: "owner",
        }
      end
      it "responds" do
        registration.reload
        get base_url, headers: authorization_headers
        expect(json_result["logs"]).to eq([registration_log_target.as_json])
        expect(json_result["links"]).to eq target_links(base_url) # In request_spec_helpers
        expect(response.code).to eq("200")
      end
    end
  end
end
