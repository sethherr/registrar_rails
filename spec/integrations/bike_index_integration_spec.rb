# frozen_string_literal: true

require "rails_helper"

RSpec.describe BikeIndexIntegration do
  let(:subject) { BikeIndexIntegration }
  let(:instance) { subject.new }

  describe "fetch_bike" do
    let(:bike) { FactoryBot.create(:vehicle, bike_index_id: 32) }
    it "fetches the bike" do
      VCR.use_cassette("bike_index_integration-fetch_bike") do
        result = instance.fetch_bike(bike)
        expect(result.keys).to eq(["bike"])
        expect(result["bike"]["serial"]).to eq "Cross-54 M11041026"
      end
    end
  end
end
