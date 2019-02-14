# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ownership, type: :model do
  describe "create_ownership" do
    let(:registration) { FactoryBot.create(:registration) }
    let(:user) { FactoryBot.create(:user) }
    context "creator: user" do
      it "creates for the user" do
        expect(Ownership.count).to eq 0
        ownership = Ownership.create_for(registration, creator: user, owner: user)
        expect(Ownership.count).to eq 1 # Manually counting because we're assigning ownership
        registration.reload
        user.reload
        expect(registration.current_owner).to eq user
        expect(user.registrations.pluck(:id)).to eq([registration.id])
        expect(user.current_registrations).to eq([registration])
        expect(ownership.user).to eq user
        expect(ownership.authorizer).to eq "authorizer_owner"
        expect(ownership.current?).to be_truthy
        expect(registration.attestations.count).to eq 1
        attestation = registration.attestations.first
        expect(attestation.user).to eq user
        expect(attestation.ownership?).to be_truthy
        expect(user.attestations).to eq([attestation])
      end
      context "updates for user" do
        let!(:ownership) { FactoryBot.create(:ownership, registration: registration, user: user) }
        let(:new_user) { FactoryBot.create(:user) }
        it "changes to a new user" do
          expect(user.current_registrations.pluck(:id)).to eq([registration.id])
          expect(Ownership.count).to eq 1
          new_ownership = Ownership.create_for(registration, creator: user, owner: new_user)
          expect(Ownership.count).to eq 2
          ownership.reload
          new_user.reload
          expect(ownership.current?).to be_falsey
          expect(user.current_registrations).to eq([])
          expect(new_user.current_registrations.pluck(:id)).to eq([registration.id])
          expect(new_ownership.user).to eq new_user
          expect(new_ownership.authorizer).to eq "authorizer_owner"
          expect(new_ownership.current?).to be_truthy
          attestation = new_ownership.attestations.last
          expect(attestation.user).to eq user # Because it's the owner who sent it
          expect(attestation.ownership?).to be_truthy
          expect(user.attestations).to eq([attestation])
        end
      end
    end
    context "creator: 'bike_index'" do
      it "creates" do
        expect(Ownership.count).to eq 0
        ownership = Ownership.create_for(registration, creator: "bike_index", owner: user)
        expect(Ownership.count).to eq 1 # Manually counting because we're assigning ownership
        registration.reload
        user.reload
        expect(registration.current_owner).to eq user
        expect(registration.current_owner_calculated).to eq user
        expect(user.registrations.pluck(:id)).to eq([registration.id])
        expect(user.current_registrations).to eq([registration])
        expect(ownership.user).to eq user
        expect(ownership.authorizer).to eq "authorizer_bike_index"
        expect(ownership.current?).to be_truthy
        expect(registration.attestations.count).to eq 1
        attestation = registration.attestations.first
        expect(attestation.authorizer).to eq "authorizer_bike_index"
        expect(attestation.user).to be_nil
        expect(attestation.ownership?).to be_truthy
      end
    end
  end
end
