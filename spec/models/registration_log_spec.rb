# frozen_string_literal: true

require "rails_helper"

RSpec.describe RegistrationLog, type: :model do
  describe "create" do
    let(:registration_log) { FactoryBot.create(:registration_log) }
    it "creates and already has the uuid" do
      expect(registration_log.uuid).to be_present
      expect(registration_log.to_param).to eq registration_log.uuid
    end
  end
end
