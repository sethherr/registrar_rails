# frozen_string_literal: true

require "rails_helper"

RSpec.describe PublicImage, type: :model do
  describe "image_url" do
    context "external_image" do
      let(:external_image_data) do
        {
          full: "https://files.bikeindex.org/uploads/Pu/136859/image-testly.jpg",
          large: "https://files.bikeindex.org/uploads/Pu/136859/large_image-testly.jpg",
          small: "https://files.bikeindex.org/uploads/Pu/136859/small_image-testly.jpg",
        }
      end
      let!(:public_image) { FactoryBot.create(:public_image, name: "", internal_image: nil, external_image: external_image_data) }
      it "returns the image urls" do
        expect(public_image.name).to eq "image-testly" # Gross hack to get name
        expect(public_image.image_url).to eq external_image_data[:full]
        expect(public_image.image_url("full")).to eq external_image_data[:full]
        expect(public_image.image_url(:small)).to eq external_image_data[:small]
        expect(public_image.image_url("large")).to eq external_image_data[:large]
      end
    end
    context "internal_image" do # Make sure that we are sending things right
      let!(:public_image) { FactoryBot.create(:public_image_internal) }
      it "returns the expected things" do
        expect(public_image.name).to be_present
        expect(public_image.image_url).to eq "/uploads/test/Pu/#{public_image.id}/surly_image.jpg"
        expect(public_image.image_url("full")).to eq "/uploads/test/Pu/#{public_image.id}/surly_image.jpg"
        expect(public_image.image_url(:small)).to eq "/uploads/test/Pu/#{public_image.id}/small_surly_image.jpg"
        expect(public_image.image_url("large")).to eq "/uploads/test/Pu/#{public_image.id}/large_surly_image.jpg"
      end
    end
  end
end
