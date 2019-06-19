# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/registration_logs", type: :request do
  describe "/registration_logs" do
    it "redirects" do
      get "/registration_logs"
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "logged in as user" do
    include_context :logged_in_as_user
    let(:registration) { FactoryBot.create(:registration_with_current_owner, user: user) }
    let(:valid_params) do
      {
        information: "This asset was serviced by the things",
        user_description: "a sweet description for my sweet log",
        kind: "service_record_log",
        registration_id: registration.id,
      }
    end
    describe "index" do
      it "redirects" do
        get "/registration_logs"
        expect(response).to redirect_to(account_path)
      end
    end

    describe "show" do
      it "redirects" do
        registration.reload
        get "/registration_logs/#{registration.current_ownership.to_param}"
        expect(response).to redirect_to(account_path)
      end
    end

    describe "new" do
      it "renders" do
        registration.reload
        get "/registration_logs/new?registration_id=#{registration.id}"
        expect(assigns(:registration)).to eq registration
        expect(response.code).to eq "200"
        expect(response).to render_template("registration_logs/new")
      end
      context "not users registration" do
        let(:registration) { FactoryBot.create(:registration_with_current_owner) }
        it "redirects" do
          registration.reload
          get "/registration_logs/new?registration_id=#{registration.to_param}"
          expect(flash[:error]).to be_present
          expect(response).to redirect_to(account_path)
        end
      end
      context "no registration" do
        it "redirects" do
          get "/registration_logs/new?registration_id=xc78xcvnanasdf"
          expect(response).to redirect_to(account_path)
        end
      end
    end

    describe "create" do
      it "creates" do
        registration.reload
        expect do
          post "/registration_logs", params: { registration_log: valid_params.merge(registration_id: registration.to_param) }
        end.to change(RegistrationLog, :count).by 1
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(registration_path(registration))
        registration_log = RegistrationLog.last

        valid_params.each do |key, value|
          pp value, key unless registration_log.send(key) == value
          expect(registration_log.send(key)).to eq value
        end
        expect(registration_log.registration).to eq registration
        expect(registration_log.authorizer_owner?).to be_truthy
        expect(registration_log.user).to eq user
      end
      context "not users registration" do
        let(:registration) { FactoryBot.create(:registration_with_current_owner) }
        it "doesn't create" do
          registration.reload
          expect do
            post "/registration_logs", params: { registration_log: valid_params.merge(registration_id: registration.to_param) }
          end.to_not change(RegistrationLog, :count)
          expect(flash[:error]).to be_present
          expect(response).to redirect_to(account_path)
        end
      end
    end
  end
end
