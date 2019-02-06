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
end
