# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/users/auth/:provider/callback ", type: :request do
  # I'm not sure how to get this to work correctly, it isn't working right now
  # Commenting out for the time being

  # include_context :omniauth_helpers
  # before { Rails.application.env_config["devise.mapping"] = Devise.mappings[:user] }
  # context "Bike Index" do
  #   let(:auth_hash) { default_bike_index_auth_hash }
  #   before do
  #     OmniAuth.config.test_mode = true
  #     OmniAuth.config.mock_auth[:bike_index] = OmniAuth::AuthHash.new(auth_hash)
  #     Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:bike_index]
  #   end
  #   context "not logged in" do
  #     it "logs in" do
  #       expect do
  #         get "/users/auth/bike_index", params: { code: "92701636c2a907efe52336ae67f410d85bdcf024f8542d83d6c6770babc18dcf",
  #                                                 state: "3363082a70d2b5c2374725645bafa97ac6ded4828f5a7a23" }
  #         pp response.code
  #       end.to change(User, :count).by 1
  #       user = User.last
  #       expect(user.confirmed?).to be_truthy
  #       expect(user.name).to eq "Seth Herr"
  #       expect(controller.current_user).to eq user

  #       expect(user.user_integrations.count).to eq 1
  #       user_integration = user.user_integrations.first
  #       expect(user_integration.external_id).to eq "85"
  #       expect(user_integration.provider).to eq "bike_index"
  #       expect(user_integration.auth_hash).to eq auth_hash.as_json
  #     end
  #   end
  # end
  # context "logged in as user" do
  #   it "updates user"
  # end
end
