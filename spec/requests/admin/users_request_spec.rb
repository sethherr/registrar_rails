# frozen_string_literal: true

require "rails_helper"

base_url = "/admin/users"

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

  context "logged in as employee" do
    include_context :logged_in_as_staff
    let(:user) { FactoryBot.create(:user, admin_role: admin_role) }
    let(:admin_role) { "manager" }

    describe "index" do
      it "renders" do
        get base_url
        expect(response.code).to eq "200"
        expect(response).to render_template("admin/users/index")
      end
    end

    describe "show" do
      it "renders" do
        get "#{base_url}/#{subject.to_param}"
        expect(response.code).to eq "200"
        expect(response).to render_template("admin/users/show")
      end
    end

    describe "edit" do
      it "renders" do
        get "#{base_url}/#{subject.to_param}/edit"
        expect(response.code).to eq "200"
        expect(response).to render_template("admin/users/edit")
      end
    end

    describe "update" do
      before { Sidekiq::Worker.clear_all }
      after { Sidekiq::Testing.fake! }
      let(:valid_params) do
        {
          manually_confirm: true,
          admin_role: "manager",
          name: "bike cooool",
          email: "party@stuff.com"
        }
      end
      context "unconfirmed" do
        let(:subject) { User.create(email: "something@stuff.com", password: "please12") }
        it "makes a user confirmed" do
          expect(subject.confirmed?).to be_falsey
          put "#{base_url}/#{subject.to_param}", params: { user: valid_params }
          expect(response).to redirect_to admin_users_path
          expect(flash[:success]).to be_present
          subject.reload
          expect(subject.confirmed?).to be_truthy
          expect(subject.admin_role).to eq "manager"
          expect(subject.name).to eq "bike cooool"
          # Doesn't update email!
          expect(subject.email).to eq "something@stuff.com"
        end
      end
    end

    describe "destroy" do
      before { expect(subject).to be_present }
      let(:admin_role) { "manager" }
      it "deletes" do
        expect do
          delete "#{base_url}/#{subject.id}"
        end.to change(User, :count).by(-1)
        expect(flash[:success]).to be_present
      end
    end
  end
end
