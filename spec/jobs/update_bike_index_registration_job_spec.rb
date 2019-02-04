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
      it "adds the registration data we expect" do
        external_registration.reload
        expect(external_registration.external_data).to eq({})
        expect(external_registration.external_data_at).to be_within(1.seconds).of og_time
        VCR.use_cassette("update_bike_index_registration_job-fetch_kona") do
          instance.perform(external_id)
        end
        registration.reload
        external_registration.reload
        expect(external_registration.external_data).to eq target_data
        expect(external_registration.external_data_at).to be_within(1.seconds).of Time.now
        expect(registration.updated_at).to be_within(1.seconds).of Time.now
      end
    end
    context "stolen bike" do
      let(:external_id) { "566562" }
      let(:target_data) { JSON.parse(File.read(Rails.root.join("spec", "fixtures", "bike_index_stolen.json"))) }
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
      end
    end
  end
end
