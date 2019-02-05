# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateBikeIndexRegistrationJob do
  let(:subject) { UpdateBikeIndexRegistrationJob }
  let(:instance) { subject.new }

  describe "perform" do
    let(:og_time) { Time.now - 4.days }
    let(:external_id) { "432199" }
    let(:target_data) { JSON.parse(File.read(Rails.root.join("spec", "fixtures", "bike_index_kona.json"))) }
    it "creates the registration and adds the info we expect" do
      VCR.use_cassette("update_bike_index_registration_job-fetch_kona") do
        expect do
          instance.perform(external_id)
        end.to change(ExternalRegistration, :count).by 1
      end
      external_registration = ExternalRegistration.last
      registration = external_registration.registration
      expect(registration.status).to eq "registered"
      expect(external_registration.external_data).to eq target_data
      expect(external_registration.external_data_at).to be_within(1.seconds).of Time.now
    end
    context "with existing external_registration" do
      let(:registration) { FactoryBot.create(:registration, updated_at: og_time) }
      let(:external_registration) do
        FactoryBot.create(:external_registration_bike_index, external_data: {},
                                                             external_data_at: og_time,
                                                             registration: registration)
      end
      let(:external_image) do
        {
          full: "https://files.bikeindex.org/uploads/Pu/136859/image.jpg",
          large: "https://files.bikeindex.org/uploads/Pu/136859/large_image.jpg",
          small: "https://files.bikeindex.org/uploads/Pu/136859/small_image.jpg"
        }.deep_stringify_keys
      end
      let!(:registration_image) do
        FactoryBot.create(:registration_image, name: "some other name",
                                               external_image: external_image,
                                               registration: registration)
      end
      it "adds the registration data we expect" do
        external_registration.reload
        expect(external_registration.external_data).to eq({})
        expect(external_registration.external_data_at).to be_within(1.seconds).of og_time
        expect(registration.registration_images.pluck(:id)).to eq([registration_image.id])
        VCR.use_cassette("update_bike_index_registration_job-fetch_kona") do
          instance.perform(external_id)
        end
        registration.reload
        external_registration.reload
        expect(external_registration.external_data).to eq target_data
        expect(external_registration.external_data_at).to be_within(1.seconds).of Time.now
        expect(registration.updated_at).to be_within(1.seconds).of Time.now
        expect(registration.registration_images.pluck(:id)).to eq([registration_image.id])
        expect(registration_image.listing_order).to eq 0
        expect(registration.thumb_url).to eq "https://files.bikeindex.org/uploads/Pu/136859/small_image.jpg"
      end
    end
    context "stolen bike" do
      let(:external_id) { "566562" }
      let(:target_data) { JSON.parse(File.read(Rails.root.join("spec", "fixtures", "bike_index_stolen.json"))) }
      let(:target_image_url) { "https://files.bikeindex.org/uploads/Pu/146611/IMG-0961.JPG" }
      let(:target_image_url_small) { "https://files.bikeindex.org/uploads/Pu/146611/small_IMG-0961.JPG" }
      let(:target_image_url_large) { "https://files.bikeindex.org/uploads/Pu/146611/large_IMG-0961.JPG" }
      it "creates the registration, marks stolen" do
        VCR.use_cassette("update_bike_index_registration_job-fetch_stolen") do
          expect do
            instance.perform(external_id)
          end.to change(ExternalRegistration, :count).by 1
        end
        external_registration = ExternalRegistration.last
        registration = external_registration.registration
        expect(registration.status).to eq "missing"
        expect(external_registration.external_data).to eq target_data
        expect(external_registration.external_data_at).to be_within(1.seconds).of Time.now

        expect(registration.registration_images.count).to eq 1
        registration_image = registration.registration_images.first
        expect(registration_image.internal_image).to be_blank
        expect(registration_image.name).to eq "2018 Trek Red"
        expect(registration_image.listing_order).to eq 0
        expect(registration.thumb_url).to eq target_image_url_small
        expect(registration_image.image_url).to eq target_image_url
        expect(registration_image.image_url(:small)).to eq target_image_url_small
        expect(registration_image.image_url(:large)).to eq target_image_url_large
      end
    end
  end
end
