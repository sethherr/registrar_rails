# frozen_string_literal: true

require "rails_helper"

RSpec.describe RegistrationLog, type: :model do
  describe "create" do
    let(:registration_log) { FactoryBot.create(:registration_log) }
    it "creates and already has the uuid" do
      expect(registration_log.to_param).to be_present
      expect(registration_log.uuid).to eq registration_log.to_param
    end
  end

  describe "description and auto_description" do
    let(:registration_log) { FactoryBot.create(:registration_log_ownership) }
    let(:target_auto_description) { "initial ownership" }
    it "returns the auto_description" do
      expect(registration_log.auto_description).to eq target_auto_description
      expect(registration_log.description).to eq target_auto_description
      registration_log.user_description = "my favorite thing"
      expect(registration_log.description).to eq "my favorite thing"
    end
  end
end
