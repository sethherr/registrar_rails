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
end
