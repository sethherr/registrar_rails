# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "factory" do
    let(:user) { FactoryBot.create(:user) }
    it "creates a valid user" do
      expect(user.valid?).to be_truthy
      expect(user.admin?).to be_falsey
      expect(user.api_key).to be_present
    end
  end

  describe "manually_confirm" do
    let(:user) { User.create(email: "stuff@s.com", password: "please12") }
    it "confirms" do
      expect(user.id).to be_present
      user.confirmed?
      user.update_attributes(manually_confirm: true)
      user.reload
      expect(user.confirmed?).to be_truthy
    end
  end

  describe "admin_search" do
    let!(:user) { FactoryBot.create(:user, email: "newseth@bikeindex.org", name: "Seth herr") }
    # Running this an integration test - since all of it closely interconnected with a bunch of disparate parts
    # I'd prefer to test the full process of creating merged users, setting the admin_search_field and search finding expected values
    it "works correctly" do
      expect(User.admin_search("Herr").pluck(:id)).to eq([user.id])
    end
  end

  describe "integrated" do
    it "returns false" do
      expect(User.new.integrated?("bike_index")).to be_falsey
    end
    context "integrated with bike_index" do
      let(:user_integration) { FactoryBot.create(:user_integration_bike_index) }
      let(:user) { user_integration.user }
      it "returns truthy" do
        expect(user.integrated?("bike_index")).to be_truthy
      end
    end
  end
end
