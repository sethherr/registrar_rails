# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/registrations", type: :request do
  describe "/registrations" do
    it "renders" do
      get "/registrations"
      expect(response.code).to eq "200"
      expect(response).to render_template("registrations/index")
    end
  end

  context "logged in as user" do
    include_context :logged_in_as_user
    let(:registration) { FactoryBot.create(:registration_with_current_owner, user: user) }
    let(:tag_main) { FactoryBot.create(:tag_main) }
    let(:tag_manufacturer) { FactoryBot.create(:tag_manufacturer) }
    let(:valid_params) do
      {
        title: "new title",
        description: "a sweet description for my sweet thing",
        main_category_tag: tag_main.name,
        manufacturer_tag: tag_manufacturer.name.upcase,
        tags_list: "some tag,another tag, beautiful favorite thing",
        status: "for_sale"
      }
    end
    describe "index" do
      it "renders" do
        get "/registrations"
        expect(response.code).to eq "200"
        expect(response).to render_template("registrations/index")
      end
    end

    describe "show" do
      it "renders" do
        registration.reload
        get "/registrations/#{registration.to_param}"
        expect(response.code).to eq "200"
        expect(response).to render_template("registrations/show")
      end
      context "not users registration" do
        let(:registration) { FactoryBot.create(:registration_with_current_owner) }
        it "redirects" do
          registration.reload
          get "/registrations/#{registration.to_param}"
          expect(flash[:error]).to be_present
          expect(response).to redirect_to(account_path)
        end
      end
      context "no registration" do
        let(:registration) { FactoryBot.create(:registration_with_current_owner) }
        it "redirects" do
          registration.reload
          get "/registrations/xc78xcvnanasdf"
          expect(response).to redirect_to(account_path)
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

    describe "create" do
      it "creates" do
        expect(Ownership.count).to eq 0
        expect do
          post "/registrations", params: { registration: valid_params }
        end.to change(Registration, :count).by 1
        registration = Registration.last

        valid_params.except(:manufacturer_tag, :tags_list).each do |key, value|
          pp value, key unless registration.send(key) == value
          expect(registration.send(key)).to eq value
        end
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

    describe "edit" do
      it "renders" do
        registration.reload
        get "/registrations/#{registration.id}/edit"
        expect(assigns(:registration)).to eq registration # Friendly find, based on id or guuid
        expect(response.code).to eq "200"
        expect(response).to render_template("registrations/edit")
      end
      context "not users registration" do
        let(:registration) { FactoryBot.create(:registration_with_current_owner) }
        it "redirects" do
          registration.reload
          get "/registrations/#{registration.to_param}/edit"
          expect(response).to redirect_to(account_path)
        end
      end
    end

    describe "update" do
      it "updates" do
        registration.reload
        expect(registration.status).to eq "registered"
        expect(Ownership.count).to eq 1
        Sidekiq::Worker.clear_all # Clear after ownership instantiated
        # For now, the transfer registration form is separate than the general update form.
        # ... But testing that it would work even if they are the same form
        put "/registrations/#{registration.to_param}", params: { registration: valid_params.merge(owner_kind: "email") }
        expect(response).to redirect_to registration_path(registration)
        expect(flash[:success]).to be_present
        registration.reload
        expect(Ownership.count).to eq 1 # just making sure

        valid_params.except(:manufacturer_tag, :tags_list).each do |key, value|
          pp value, key unless registration.send(key) == value
          expect(registration.send(key)).to eq value
        end
        expect(registration.manufacturer).to eq tag_manufacturer # separate because capitals
        expect(registration.tags_list).to eq valid_params[:tags_list].split(",").map(&:strip) # separate because array
        expect(registration.current_owner).to eq user
        expect(SendOwnershipCreationNotificationJob.jobs.count).to eq 0
      end
      context "adding photos" do
        let(:photo) { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "spec", "fixtures", "surly_image.jpg"))) }
        let(:valid_params) do
          {
            public_images_attributes: {
              "0" => {
                image: photo,
                image_cache: "",
                _destroy: "0",
                id: nil
              }
            }
          }
        end
        it "adds photos" do
          registration.reload
          expect(registration.public_images.count).to eq 0
          put "/registrations/#{registration.to_param}", params: { registration: valid_params }
          registration.reload
          expect(registration.public_images.count).to eq 1
          expect(registration.public_images.first.image_url).to be_present
          expect(registration.thumb_url).to be_present
        end
      end
      context "new owner" do
        it "updates" do
          registration.reload
          expect(registration.status).to eq "registered"
          Sidekiq::Worker.clear_all # Clear after ownership instantiated
          # For now, the transfer registration form is separate than the general update form.
          # ... But testing that it would work even if they are the same form
          expect do
            put "/registrations/#{registration.to_param}", params: { registration: valid_params.merge(new_owner: "seth@test.com", new_owner_kind: "email") }
          end.to change(Ownership, :count).by 1
          expect(response).to redirect_to account_path
          expect(flash[:success]).to be_present
          registration.reload

          valid_params.except(:manufacturer_tag, :tags_list).each do |key, value|
            pp value, key unless registration.send(key) == value
            expect(registration.send(key)).to eq value
          end
          expect(registration.manufacturer).to eq tag_manufacturer # separate because capitals
          expect(registration.tags_list).to eq valid_params[:tags_list].split(",").map(&:strip) # separate because array
          expect(registration.current_owner).to_not eq user

          # And check that the ownership was created correctly
          ownership2 = registration.current_ownership
          expect(ownership2.valid?).to be_truthy
          expect(ownership2.current?).to be_truthy
          expect(ownership2.external_id).to eq "seth@test.com"
          expect(ownership2.initial_owner_kind).to eq "initial_owner_email"
          expect(SendOwnershipCreationNotificationJob.jobs.map { |j| j["args"] }.flatten).to eq([ownership2.id])
        end
      end
    end
  end
end
