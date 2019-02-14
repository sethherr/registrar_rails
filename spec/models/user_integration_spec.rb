# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserIntegration, type: :model do
  describe "factory" do
    let(:user_integration) { FactoryBot.create(:user_integration_bike_index) }
    it "is valid" do
      expect(user_integration.valid?).to be_truthy
    end
  end

  describe "user_from_omniauth" do
    context "unknown provider" do
      it "errors" do
        expect do
          expect do
            UserIntegration.user_from_omniauth(nil, "facebook", "85", {})
          end.to raise_error(/unknown.provider/i)
        end.to_not change(User, :count)
      end
      context "nil provider" do
        it "errors" do
          expect do
            expect do
              UserIntegration.user_from_omniauth(nil, " ", "85", {})
            end.to raise_error(/unknown.provider/i)
          end.to_not change(User, :count)
        end
      end
    end
    context "bike_index provider" do
      include_context :omniauth_helpers
      let(:auth_hash) { default_bike_index_auth_hash }
      # Make an object rather than hash
      let(:auth) { OmniAuth::AuthHash.new(auth_hash) }
      it "creates a confirmed user" do
        expect do
          UserIntegration.user_from_omniauth(nil, "bike_index", "85", auth)
        end.to change(User, :count).by 1
        user = User.last
        expect(user.confirmed?).to be_truthy
        expect(user.name).to eq "Seth Herr"

        expect(user.user_integrations.count).to eq 1
        user_integration = user.user_integrations.first
        expect(user_integration.external_id).to eq "85"
        expect(user_integration.provider).to eq "bike_index"
        expect(user_integration.auth_hash).to eq auth_hash.as_json
      end
      context "existing integration" do
        let(:user_integration) { FactoryBot.create(:user_integration_bike_index, external_id: "85", auth_hash: {}) }
        let!(:user) { user_integration.user }
        it "does not create anything" do
          expect(UserIntegration.count).to eq 1
          expect do
            UserIntegration.user_from_omniauth(nil, "bike_index", "85", auth)
          end.to_not change(User, :count)
          expect(UserIntegration.count).to eq 1
          user_integration.reload
          expect(user_integration.auth_hash).to eq auth_hash.as_json
        end
      end

      context "authed_user_id" do
        let!(:user) { FactoryBot.create(:user) }
        it "adds to the user" do
          expect(user.confirmed?).to be_truthy
          expect(user.user_integrations.count).to eq 0
          expect do
            UserIntegration.user_from_omniauth(user.id, "bike_index", "85", auth)
          end.to_not change(User, :count)
          user.reload
          expect(user.confirmed?).to be_truthy
          expect(user.user_integrations.count).to eq 1
          user_integration = user.user_integrations.first
          expect(user_integration.external_id).to eq "85"
          expect(user_integration.provider).to eq "bike_index"
          expect(user_integration.auth_hash).to eq auth_hash.as_json
        end
      end

      describe "existing user" do
        let!(:user) { User.create(email: "seth@bikeindex.orgd", name: " ", password: "partypass1111") }
        let(:target_job_ids) { [6, 32, 35] }
        it "updates name, not password" do
          Sidekiq::Worker.clear_all
          expect(user.confirmed?).to be_falsey
          expect(user.valid_password?("partypass1111")).to be_truthy
          expect do
            UserIntegration.user_from_omniauth(nil, "bike_index", "85", auth)
          end.to_not change(User, :count)
          user.reload
          expect(user.confirmed?).to be_truthy
          expect(user.name).to eq "Seth Herr"
          expect(user.valid_password?("partypass1111")).to be_truthy
          expect(user.user_integrations.count).to eq 1
          user_integration = user.user_integrations.first
          expect(user_integration.external_id).to eq "85"
          expect(user_integration.provider).to eq "bike_index"
          expect(user_integration.auth_hash).to eq auth_hash.as_json
          # Check that we successfully enqueue update_bike_index_registration_job
          expect(UpdateBikeIndexRegistrationJob.jobs.map { |j| j["args"] }.flatten).to match_array target_job_ids
        end
      end
    end
  end
end
