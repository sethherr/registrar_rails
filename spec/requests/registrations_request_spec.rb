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
    let(:tag_main) { FactoryBot.create(:tag_main) }
    let(:tag_manufacturer) { FactoryBot.create(:tag_manufacturer) }
    let(:valid_params) do
      {
        title: "new title",
        description: "a sweet description for my sweet thing",
        main_category_tag: tag_main.name,
        manufacturer_tag: tag_manufacturer.name.upcase,
        tags_list: "some tag,another tag, beautiful favorite thing"
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
        let(:registration) { FactoryBot.create(:registration_with_owner) }
        it "renders" do
          registration.reload
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
        expect(registration.attestations.count).to eq 1
        attestation = registration.attestations.first
        expect(attestation.user).to eq user
        expect(attestation.ownership?).to be_truthy
        expect(user.attestations).to eq([attestation])
      end
    end
  end
end
