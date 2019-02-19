# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/attestations", type: :request do
  describe "/attestations" do
    it "redirects" do
      get "/attestations"
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "logged in as user" do
    include_context :logged_in_as_user
    let(:registration) { FactoryBot.create(:registration_with_current_owner, user: user) }
    let(:valid_params) do
      {
        title: "new title",
        description: "a sweet description for my sweet attestation",
        kind: "service_record_attestation",
        registration_id: registration.id
      }
    end
    describe "index" do
      it "redirects" do
        get "/attestations"
        expect(response).to redirect_to(account_path)
      end
    end

    describe "show" do
      it "redirects" do
        registration.reload
        get "/attestations/#{registration.current_ownership.to_param}"
        expect(response).to redirect_to(account_path)
      end
    end

    describe "new" do
      it "renders" do
        registration.reload
        get "/attestations/new?registration_id=#{registration.id}"
        expect(assigns(:registration)).to eq registration
        expect(response.code).to eq "200"
        expect(response).to render_template("attestations/new")
      end
      context "not users registration" do
        let(:registration) { FactoryBot.create(:registration_with_current_owner) }
        it "redirects" do
          registration.reload
          get "/attestations/new?registration_id=#{registration.to_param}"
          expect(flash[:error]).to be_present
          expect(response).to redirect_to(account_path)
        end
      end
      context "no registration" do
        it "redirects" do
          get "/attestations/new?registration_id=xc78xcvnanasdf"
          expect(response).to redirect_to(account_path)
        end
      end
    end

    describe "create" do
      it "creates" do
        registration.reload
        expect do
          post "/attestations", params: { attestation: valid_params.merge(registration_id: registration.to_param) }
        end.to change(Attestation, :count).by 1
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(registration_path(registration))
        attestation = Attestation.last

        valid_params.each do |key, value|
          pp value, key unless attestation.send(key) == value
          expect(attestation.send(key)).to eq value
        end
        expect(attestation.registration).to eq registration
        expect(attestation.authorizer_owner?).to be_truthy
        expect(attestation.user).to eq user
      end
      context "not users registration" do
        let(:registration) { FactoryBot.create(:registration_with_current_owner) }
        it "doesn't create" do
          registration.reload
          expect do
            post "/attestations", params: { attestation: valid_params.merge(registration_id: registration.to_param) }
          end.to_not change(Attestation, :count)
          expect(flash[:error]).to be_present
          expect(response).to redirect_to(account_path)
        end
      end
    end
  end
end
