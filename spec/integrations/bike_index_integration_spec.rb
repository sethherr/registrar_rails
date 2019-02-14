# frozen_string_literal: true

require "rails_helper"

RSpec.describe BikeIndexIntegration do
  let(:subject) { BikeIndexIntegration }
  let(:instance) { subject.new }

  describe "fetch_bike" do
    let(:target_keys) do
      %w[id title serial manufacturer_name frame_model year frame_colors thumb large_img is_stock_img stolen stolen_location
         date_stolen registration_created_at registration_updated_at url api_url manufacturer_id paint_description name
         frame_size description rear_tire_narrow front_tire_narrow type_of_cycle test_bike rear_wheel_size_iso_bsd
         front_wheel_size_iso_bsd handlebar_type_slug frame_material_slug front_gear_type_slug rear_gear_type_slug
         stolen_record public_images components]
    end
    it "fetches the bike index data" do
      VCR.use_cassette("bike_index_integration-fetch_bike") do
        result = instance.fetch_bike(32)
        expect(result.keys).to eq target_keys
      end
    end
  end
end
