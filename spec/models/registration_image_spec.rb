# frozen_string_literal: true

require "rails_helper"

RSpec.describe RegistrationImage, type: :model do
  describe "image_url" do
    context "external_image" do
      let(:external_image_data) do
        {
          full: "https://files.bikeindex.org/uploads/Pu/136859/image-testly.jpg",
          large: "https://files.bikeindex.org/uploads/Pu/136859/large_image-testly.jpg",
          small: "https://files.bikeindex.org/uploads/Pu/136859/small_image-testly.jpg"
        }
      end
      let!(:registration_image) { FactoryBot.create(:registration_image, name: "", internal_image: nil, external_image: external_image_data) }
      it "returns the image urls" do
        expect(registration_image.name).to eq "image-testly" # Gross hack to get name
        expect(registration_image.image_url).to eq external_image_data[:full]
        expect(registration_image.image_url("full")).to eq external_image_data[:full]
        expect(registration_image.image_url(:small)).to eq external_image_data[:small]
        expect(registration_image.image_url("large")).to eq external_image_data[:large]
      end
    end
    context "internal_image" do # Make sure that we are sending things right
      let!(:registration_image) { FactoryBot.create(:registration_image_internal) }
      it "returns the expected things" do
        expect(registration_image.name).to be_present
        expect(registration_image.image_url).to eq "/uploads/test/Re/#{registration_image.id}/surly_image.jpg"
        expect(registration_image.image_url("full")).to eq "/uploads/test/Re/#{registration_image.id}/surly_image.jpg"
        expect(registration_image.image_url(:small)).to eq "/uploads/test/Re/#{registration_image.id}/small_surly_image.jpg"
        expect(registration_image.image_url("large")).to eq "/uploads/test/Re/#{registration_image.id}/large_surly_image.jpg"
      end
    end
  end
end
