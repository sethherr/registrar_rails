# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/account", type: :request do
  describe "/account" do
    it "redirects" do
      get "/account"
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "logged in as user" do
    include_context :logged_in_as_user
    describe "/account" do
      it "renders" do
        get "/account"
        expect(response.code).to eq "200"
        expect(response).to render_template("accounts/show")
      end
    end
    describe "/account/edit" do
      it "renders" do
        get "/account/edit"
        expect(response.code).to eq "200"
        expect(response).to render_template("accounts/edit")
      end
    end
    describe "update" do
      let(:params) do
        {
          email: "rad_new_email@bike.com",
          admin_role: "manager",
          name: "cooool name"
        }
      end
      it "updates a user" do
        og_email = user.email
        put "/account", params: { user: params }
        expect(response).to redirect_to account_path
        expect(flash[:success]).to be_present
        user.reload
        expect(user.admin_role).to eq "not"
        expect(user.name).to eq "cooool name"
        expect(user.email).to eq og_email
      end
    end
  end
end
