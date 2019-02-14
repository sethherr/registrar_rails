# frozen_string_literal: true

require "rails_helper"

base_url = "/admin/registrations"

RSpec.describe base_url, type: :request do
  let(:subject) { FactoryBot.create(:user) }
  context "not logged in" do
    describe "index" do
      it "redirects" do
        get base_url
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context "logged in as user" do
    include_context :logged_in_as_user
    describe "index" do
      it "redirects" do
        get base_url
        expect(response).to redirect_to(root_path)
      end
    end
  end

  context "logged in as admin" do
    include_context :logged_in_as_staff
    let(:user) { FactoryBot.create(:user, admin_role: admin_role) }
    let(:admin_role) { "manager" }

    describe "index" do
      it "renders" do
        get base_url
        expect(response.code).to eq "200"
        expect(response).to render_template("admin/registrations/index")
      end
    end

    describe "show" do
      let(:external_registration) { FactoryBot.create(:external_registration_bike_index) }
      let!(:registration) { external_registration.registration }
      it "renders" do
        get "#{base_url}/#{registration.id}"
        expect(response.code).to eq "200"
        expect(response).to render_template("admin/registrations/show")
      end
    end
  end
end
