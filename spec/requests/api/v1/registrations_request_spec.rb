# frozen_string_literal: true

require "rails_helper"

base_url = "/api/v1/registrations"

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
  end

  context "logged in" do
    let(:tag_main) { FactoryBot.create(:tag_main) }
    let(:tag_manufacturer) { FactoryBot.create(:tag_manufacturer) }
    describe "/" do
      let!(:registration) { FactoryBot.create(:registration_with_current_owner, user: user, main_category_tag: tag_main.name, manufacturer_tag: tag_manufacturer.name.upcase) }
      let(:registration_log_ownership) { registration.current_ownership }
      let(:registration_log_target) { { recorded_at: registration_log_ownership.created_at.to_i, kind: "ownership", title: nil, description: nil, authorizer: "owner" } }
      let(:target) do
        {
          id: registration.to_param,
          registered_at: registration.created_at.to_i,
          manufacturer: tag_manufacturer.name,
          main_category: tag_main.name,
          title: registration.title,
          description: registration.description,
          status: "registered",
          tags_list: [],
          images: [],
          registration_logs: [registration_log_target]
        }
      end
      it "responds" do
        registration.reload
        expect(registration.manufacturer).to eq tag_manufacturer # separate because capitals
        get base_url, headers: authorization_headers
        expect(json_result["registrations"]).to eq([target.as_json])
        expect(json_result["links"]).to eq target_links(base_url) # In request_spec_helpers
        expect(response.code).to eq("200")
      end
    end

    describe "create" do
      let(:valid_params) do
        {
          title: "new title",
          description: "a sweet description for my sweet thing",
          main_category: tag_main.name,
          manufacturer: tag_manufacturer.name.upcase,
          tags_list: "some tag,another tag, beautiful favorite thing",
          status: "for_sale"
        }
      end
      it "creates" do
        expect(Ownership.count).to eq 0
        expect do
          post base_url, params: valid_params.to_json, headers: authorization_headers
        end.to change(Registration, :count).by 1
        registration = Registration.last

        matched_result = json_result["registration"].except(:registered_at, :registration_logs, :tags_list, :manufacturer)
        expect(matched_result).to eq valid_params.except(:tags_list, :manufacturer).merge(id: registration.to_param, images: []).as_json
        expect(registration.manufacturer).to eq tag_manufacturer # separate because capitals
        expect(registration.tags_list).to eq valid_params[:tags_list].split(",").map(&:strip) # separate because array

        expect(Ownership.count).to eq 1 # Manually counting because we're assigning ownership
        ownership = registration.current_ownership
        user.reload
        expect(registration.current_owner).to eq user
        expect(user.registrations.pluck(:id)).to eq([registration.id])
        expect(user.current_registrations).to eq([registration])
        expect(ownership.user).to eq user
        expect(ownership.authorizer).to eq "authorizer_owner"
        expect(ownership.current?).to be_truthy
        expect(registration.registration_logs.count).to eq 1
        registration_log = registration.registration_logs.first
        expect(registration_log.user).to eq user
        expect(registration_log.ownership_log?).to be_truthy
        expect(user.registration_logs).to eq([registration_log])
      end
    end
  end
end
