# frozen_string_literal: true

require "rails_helper"

RSpec.describe RegistrationLog, type: :model do
  describe "create" do
    let(:registration_log) { FactoryBot.create(:registration_log) }
    it "creates and already has the uuid" do
      pp registration_log.to_param
      expect(registration_log.to_param).to be_present
      expect(registration_log.uuid).to eq registration_log.to_param
    end
  end
end
