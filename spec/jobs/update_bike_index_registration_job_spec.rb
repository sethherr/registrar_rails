# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateBikeIndexRegistrationJob do
  let(:subject) { UpdateBikeIndexRegistrationJob }
  let(:instance) { subject.new }

  describe "perform" do
    let(:og_time) { Time.current - 4.days }
    let(:external_id) { "432199" }
    let(:target_data) { JSON.parse(File.read(Rails.root.join("spec", "fixtures", "bike_index_kona.json"))) }
    let(:og_description) { "My favorite mountain bike. I put holes in everything" }

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
      expect(external_registration.external_data_at).to be_within(1.seconds).of Time.current
      expect(registration.main_category_tag).to eq "Bicycle"
      expect(registration.manufacturer_tag).to eq "Kona"
      expect(registration.description).to eq "My favorite mountain bike. I put holes in everything"
      expect(registration.title).to eq "2018 Kona Big honzo st"
      expect(registration.ownerships).to eq([])
    end
    # context "with existing external_registration" do
    #   let(:registration) do
    #     FactoryBot.create(:registration, manufacturer_tag: "KKONA",
    #                                      updated_at: og_time,
    #                                      description: "Some cool other thing",
    #                                      title: "party party party")
    #   end
    #   let(:external_registration) do
    #     FactoryBot.create(:external_registration_bike_index, external_data: {},
    #                                                          external_data_at: og_time,
    #                                                          registration: registration)
    #   end
    #   let!(:public_image) do
    #     FactoryBot.create(:public_image, name: "some other name",
    #                                      remote_image_url: "https://files.bikeindex.org/uploads/Pu/136859/image.jpg",
    #                                      imageable: registration)
    #   end
    #   let!(:ownership) { FactoryBot.create(:ownership, registration: registration) }
    #   it "adds the registration data we expect, overrides manufacturer_tag, doesn't create a new ownership" do
    #     external_registration.reload
    #     expect(external_registration.external_data).to eq({})
    #     expect(external_registration.external_data_at).to be_within(1.seconds).of og_time
    #     expect(registration.public_images.pluck(:id).include?(public_image.id)).to be_truthy
    #     expect(ownership.current?).to be_truthy
    #     expect(registration.current_ownership).to eq(ownership)
    #     VCR.use_cassette("update_bike_index_registration_job-fetch_kona") do
    #       instance.perform(external_id, ownership.user_id)
    #     end
    #     registration.reload
    #     external_registration.reload
    #     ownership.reload
    #     expect(ownership.current?).to be_truthy
    #     expect(registration.current_ownership).to eq(ownership)
    #     expect(external_registration.external_data).to eq target_data
    #     expect(external_registration.external_data_at).to be_within(1.seconds).of Time.current
    #     expect(registration.updated_at).to be_within(1.seconds).of Time.current
    #     expect(registration.status).to eq "registered"
    #     expect(registration.public_images.pluck(:id).include?(public_image.id)).to be_truthy
    #     expect(registration.public_images.count).to eq 4
    #     expect(public_image.listing_order).to eq 0
    #     expect(registration.thumb_url).to eq "https://files.bikeindex.org/uploads/Pu/147262/small_IMG_3970.JPG"
    #     expect(registration.main_category_tag).to eq "Bicycle"
    #     expect(registration.manufacturer_tag).to eq "KKONA"
    #     expect(registration.description).to eq "Some cool other thing"
    #     expect(registration.title).to eq "party party party"
    #   end
    # end
    context "stolen bike" do
      let(:external_id) { "623931" }
      let(:target_data) { JSON.parse(File.read(Rails.root.join("spec", "fixtures", "bike_index_stolen.json"))) }
      let(:target_image_external_url) { "https://files.bikeindex.org/uploads/Pu/163630/00000IMG_00000_BURST20181230130042985_COVER.jpg" }
      let(:user) { FactoryBot.create(:user) }
      it "creates the registration, marks stolen" do
        # Don't be surprised when this cassette breaks, the bike will definitely be changed again
        VCR.use_cassette("update_bike_index_registration_job-fetch_stolen") do
          expect do
            instance.perform(external_id, user.id)
          end.to change(ExternalRegistration, :count).by 1
        end
        external_registration = ExternalRegistration.last
        registration = external_registration.registration
        expect(registration.status).to eq "missing"
        expect(external_registration.external_data).to eq target_data

        expect(registration.public_images.count).to eq 1
        public_image = registration.public_images.first
        expect(public_image.image).to be_present
        expect(public_image.name).to eq "2018 Cannondale Synapse Blue and Black"
        expect(public_image.listing_order).to eq 0
        expect(registration.thumb_url).to eq public_image.image_url(:small)
        expect(public_image.external_url).to eq target_image_external_url

        user.reload
        expect(registration.ownerships.count).to eq 1
        expect(registration.registration_logs.count).to eq 1
        ownership = registration.current_ownership
        expect(registration.current_owner).to eq user
        expect(user.registrations.pluck(:id)).to eq([registration.id])
        expect(user.current_registrations).to eq([registration])
        expect(ownership.user).to eq user
        expect(ownership.authorizer).to eq "authorizer_bike_index"
        expect(ownership.current?).to be_truthy
      end
    end
  end
end
