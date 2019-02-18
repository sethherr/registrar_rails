# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExternalRegistration, type: :model do
  describe "uniqueness" do
    let!(:external_registration1) { FactoryBot.create(:external_registration, provider: "bike_index", external_id: "111") }
    let(:external_registration2) { FactoryBot.build(:external_registration, provider: "bike_index", external_id: "111") }
    let(:external_registration3) { FactoryBot.create(:external_registration, provider: "globalid", external_id: "111") }
    it "only permits one external registration with a given id" do
      expect(external_registration1.valid?).to be_truthy
      expect(external_registration2.save).to be_falsey
      expect(external_registration2.id).to be_blank
      expect(external_registration3.save).to be_truthy
      expect(external_registration3.valid?).to be_truthy
    end
  end
end
