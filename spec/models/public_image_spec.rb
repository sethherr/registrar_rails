# frozen_string_literal: true

require "rails_helper"

RSpec.describe PublicImage, type: :model do
  describe "image_url" do
    let!(:public_image) { FactoryBot.create(:public_image) }
    it "returns the expected things" do
      expect(public_image.name).to be_present
      expect(public_image.image_url).to eq "/uploads/test/Pu/#{public_image.id}/surly_image.jpg"
      expect(public_image.image_url).to eq "/uploads/test/Pu/#{public_image.id}/surly_image.jpg"
      expect(public_image.image_url(:small)).to eq "/uploads/test/Pu/#{public_image.id}/small_surly_image.jpg"
      expect(public_image.image_url("large")).to eq "/uploads/test/Pu/#{public_image.id}/large_surly_image.jpg"
    end
  end
  describe "remote_image_url" do
    let(:external_url) { "https://files.bikeindex.org/uploads/Pu/146611/small_IMG-0961.JPG" }
    let(:public_image) { FactoryBot.create(:public_image, image: nil, remote_image_url: external_url) }
    it "sets the url" do
      VCR.use_cassette("public_image-remote_image_url") do
        public_image.reload
        expect(public_image.image).to be_present
        expect(public_image.external_url).to eq external_url
      end
    end
  end
end
