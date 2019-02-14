# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/registrations", type: :request do
  describe "/registrations" do
    it "redirects" do
      get "/registrations"
      expect(response.code).to eq "200"
      expect(response).to render_template("registrations/index")
    end
  end

  context "logged in as user" do
    include_context :logged_in_as_user
    let(:registration) { FactoryBot.create(:registration_with_owner, user: user) }
    describe "index" do
      it "renders" do
        get "/registrations"
        expect(response.code).to eq "200"
        expect(response).to render_template("registrations/index")
      end
    end

    describe "show" do
      it "renders" do
        get "/registrations/#{registration.to_param}"
        expect(response.code).to eq "200"
        expect(response).to render_template("registrations/show")
      end
      context "not users registration" do
        let(:registration) { FactoryBot.create(:registration_with_owner) }
        it "renders" do
          get "/registrations/#{registration.to_param}"
          expect(response.code).to eq "200"
          expect(response).to render_template("registrations/show")
        end
      end
    end

    describe "new" do
      it "renders" do
        get "/registrations/new"
        expect(response.code).to eq "200"
        expect(response).to render_template("registrations/new")
      end
    end

    # describe "/registrations/edit" do
    #   it "renders" do
    #     get "/registrations/#{registration.to_param}/edit"
    #     expect(response.code).to eq "200"
    #     expect(response).to render_template("registrations/edit")
    #   end
    #   context "not users registration" do
    #     let(:registration) { FactoryBot.create(:registration_with_owner) }
    #     it "404s" do
    #       expect(registration.current_owner).to_not eq user
    #       expect do
    #         get "/registrations/#{registration.to_param}/edit"
    #       end.to raise_error
    #       expect(response.code).to eq "404"
    #     end
    #   end
    # end

    # describe "update" do
    #   let(:params) do
    #     {
    #       email: "rad_new_email@bike.com",
    #       admin_role: "manager",
    #       name: "cooool name"
    #     }
    #   end
    #   it "updates a user" do
    #     og_email = user.email
    #     put "/registrations", params: { user: params }
    #     expect(response).to redirect_to registrations_path
    #     expect(flash[:success]).to be_present
    #     user.reload
    #     expect(user.admin_role).to eq "not"
    #     expect(user.name).to eq "cooool name"
    #     expect(user.email).to eq og_email
    #   end
    # end
  end
end
