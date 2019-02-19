# frozen_string_literal: true

require "rails_helper"

RSpec.describe Registration, type: :model do
  describe "lookup_external_id" do
    let(:external_registration) { FactoryBot.create(:external_registration_bike_index) }
    let!(:registration) { external_registration.registration }
    it "finds the record" do
      expect(external_registration.valid?).to be_truthy
      expect(external_registration.external_id.to_i).to eq 432199 # Validate, because type coercion
      expect(Registration.lookup_external_id("bike_index", 432199)).to eq registration
      expect(Registration.lookup_external_id("bike_index", "432199 ")).to eq registration
      # Also, doesn't explode when it isn't there
      expect(Registration.lookup_external_id("bike_index", "z")).to be_nil
    end
  end

  describe "assigning main_category and manufacturer tags" do
    let!(:tag) { FactoryBot.create(:tag, name: "A Special Tag") }
    let!(:tag_main) { FactoryBot.create(:tag, name: "Vehicle", main_category: true) }
    let!(:tag_manufacturer) { FactoryBot.create(:tag, name: "Ford", manufacturer: true) }
    context "assigning both in tags" do
      let(:registration) do
        FactoryBot.create(:registration, manufacturer_tag: "A Special Tag ",
                                         main_category_tag: "Vehicle",
                                         tags_list: ["Vehicle", "A Special Tag", "ford"])
      end
      it "assigns them, and de-duplicates" do
        expect(tag_main.main_category?).to be_truthy
        expect(tag.manufacturer?).to be_falsey
        registration.reload
        expect(registration.uuid).to be_present
        expect(registration.tags.count).to eq 3
        expect(registration.manufacturer_id).to eq tag.id
        expect(registration.main_category_id).to eq tag_main.id
        expect(registration.tags.pluck(:id)).to match_array([tag_main.id, tag_manufacturer.id, tag.id])
      end
    end
    context "only tags assigned" do
      let(:registration) do
        FactoryBot.build(:registration, manufacturer_tag: " ",
                                        main_category_tag: nil,
                                        tags_list: "Vehicle, A Special Tag,ford,New Tag ")
      end
      it "makes it a vehicle" do
        registration.save
        expect(registration.tags.count).to eq 4
        expect(registration.manufacturer_id).to eq tag_manufacturer.id
        expect(registration.main_category_id).to eq tag_main.id
        new_tag = Tag.order(:created_at).last
        expect(new_tag.name).to eq "New Tag" # It strips the name
        expect(registration.tags.pluck(:id)).to match_array([tag_main.id, tag_manufacturer.id, tag.id, new_tag.id])
      end
    end
  end

  describe "transfer_ownership" do
    let(:registration) { FactoryBot.create(:registration_with_current_owner) }
    let(:ownership) { registration.current_ownership }
    let(:user) { registration.current_owner }
    let(:user2) { FactoryBot.create(:user) }
    before do
      expect(ownership).to be_present # Create and then clear queue
      Sidekiq::Worker.clear_all
    end
    context "user_id" do
      it "accepts user_id" do
        expect(ownership.current?).to be_truthy
        ownership2 = registration.transfer_ownership(user, user_id: user2.id)
        expect(ownership2.valid?).to be_truthy
        expect(ownership2.current?).to be_truthy
        expect(ownership2.external_id).to be_nil
        expect(ownership2.initial_owner_kind).to eq "initial_owner_user"
        ownership.reload
        expect(ownership.previous?).to be_truthy
        expect(registration.current_owner).to eq user2
        expect(registration.current_ownership).to eq ownership2
        expect(user2.registrations.pluck(:id)).to eq([registration.id])
        expect(SendOwnershipCreationNotificationJob.jobs.map { |j| j["args"] }.flatten).to eq([ownership2.id])
      end
    end
    context "email" do
      let(:email) { "something@stuff.com" }
      it "accepts email, only enqueues one notification job" do
        expect(ownership.current?).to be_truthy
        ownership2 = registration.transfer_ownership(user, email: email)
        expect(ownership2.valid?).to be_truthy
        expect(ownership2.current?).to be_truthy
        expect(ownership2.external_id).to eq "something@stuff.com"
        expect(ownership2.initial_owner_kind).to eq "initial_owner_email"
        ownership.reload
        expect(ownership.previous?).to be_truthy
        expect(registration.current_owner).to be_nil
        expect(registration.current_ownership).to eq ownership2
        expect(SendOwnershipCreationNotificationJob.jobs.map { |j| j["args"] }.flatten).to eq([ownership2.id])
      end
      context "user email" do
        let(:email) { user2.email }
        it "assigns the ownership too" do
          expect(user2).to be_present
          expect(ownership.current?).to be_truthy
          ownership2 = registration.transfer_ownership(user, email: email)
          expect(ownership2.valid?).to be_truthy
          expect(ownership2.current?).to be_truthy
          expect(ownership2.external_id).to eq email
          expect(ownership2.initial_owner_kind).to eq "initial_owner_email"
          ownership.reload
          expect(ownership.previous?).to be_truthy
          expect(registration.current_owner).to eq user2
          expect(registration.current_ownership).to eq ownership2
          expect(user2.registrations.pluck(:id)).to eq([registration.id])
          expect(SendOwnershipCreationNotificationJob.jobs.map { |j| j["args"] }.flatten).to eq([ownership2.id])
        end
      end
    end
    context "globalid" do
      it "accepts globalid, only enqueues one notification job" do
        expect(ownership.current?).to be_truthy
        ownership2 = registration.transfer_ownership(user, globalid: "sethherr")
        expect(ownership2.valid?).to be_truthy
        expect(ownership2.current?).to be_truthy
        expect(ownership2.external_id).to eq "sethherr"
        expect(ownership2.initial_owner_kind).to eq "initial_owner_globalid"
        ownership.reload
        expect(ownership.previous?).to be_truthy
        expect(registration.current_owner).to be_nil
        expect(registration.current_ownership).to eq ownership2
        expect(SendOwnershipCreationNotificationJob.jobs.map { |j| j["args"] }.flatten).to eq([ownership2.id])
      end
    end
  end
end
