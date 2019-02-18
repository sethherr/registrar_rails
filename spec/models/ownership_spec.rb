# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ownership, type: :model do
  describe "factories" do
    # Because of the combination of ownership and attestation, test factories create things correctly
    context "registration" do
      let(:registration) { FactoryBot.create(:registration_with_current_owner) }
      it "creates the associations correctly" do
        expect(registration.valid?).to be_truthy
        expect(registration.ownerships.count).to eq 1
        expect(registration.attestations.count).to eq 1
        expect(registration.current_ownership.attestations.count).to eq 1
        expect(registration.ownerships.first.attestations.first).to eq registration.attestations.first
      end
    end
    context "ownership" do
      let(:ownership) { FactoryBot.create(:ownership) }
      it "creates the associations correctly" do
        expect(ownership.valid?).to be_truthy
        expect(ownership.attestations.count).to eq 1
        attestation = ownership.attestations.first
        expect(attestation.kind).to eq "ownership_attestation"
        expect(ownership.registration).to be_present
        expect(attestation.registration).to eq ownership.registration
        expect(attestation.ownership).to eq ownership
        expect(attestation.registration.ownerships.pluck(:id)).to eq([ownership.id])
        expect(ownership.registration.attestations.pluck(:id)).to eq([attestation.id])
      end
    end
    context "attestation" do
      let(:attestation) { FactoryBot.create(:attestation_ownership) }
      it "creates the associations correctly" do
        expect(attestation.valid?).to be_truthy
        expect(attestation.kind).to eq "ownership_attestation"
        expect(attestation.ownership).to be_present
        expect(attestation.registration).to be_present
        ownership = attestation.ownership
        expect(ownership.attestations.pluck(:id)).to eq([attestation.id])
        expect(attestation.registration).to eq ownership.registration
        expect(attestation.registration.ownerships.pluck(:id)).to eq([ownership.id])
        expect(ownership.registration.attestations.pluck(:id)).to eq([attestation.id])
      end
    end
  end

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
        expect(attestation.ownership_attestation?).to be_truthy
        expect(attestation.ownership).to eq ownership
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
          expect(attestation.ownership_attestation?).to be_truthy
          expect(user.attestations.pluck(:id)).to eq([ownership.attestations.first.id, attestation.id])
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
        expect(ownership.creation_notification_kind).to eq "no_creation_notification"
        attestation = registration.attestations.first
        expect(attestation.authorizer).to eq "authorizer_bike_index"
        expect(attestation.user).to be_nil
        expect(attestation.ownership_attestation?).to be_truthy
      end
    end
  end

  describe "owner" do
    let(:user) { FactoryBot.create(:user) }
    let(:ownership) { Ownership.new(initial_owner_kind: initial_owner_kind, owner: new_owner) }
    context "user" do
      let(:initial_owner_kind) { "initial_owner_user" }
      let(:new_owner) { user }
      it "sets the owner, default creation_notification" do
        expect(ownership.user).to eq user
        expect(ownership.external_id).to be_nil
        expect(ownership.creation_notification_kind).to eq "no_creation_notification"
      end
      context "with assigned email_creation_notification" do
        let(:ownership) { Ownership.new(initial_owner_kind: initial_owner_kind, owner: new_owner, creation_notification_kind: "email_creation_notification") }
        it "sets, sends email" do
          expect(ownership.user).to eq user
          expect(ownership.external_id).to be_nil
          expect(ownership.creation_notification_kind).to eq "email_creation_notification"
        end
      end
    end
    context "email" do
      let(:initial_owner_kind) { "initial_owner_email" }
      let(:new_owner) { "party@stuff.com" }
      it "sets the owner, default creation_notification" do
        expect(ownership.user).to be_nil
        expect(ownership.external_id).to eq new_owner
        expect(ownership.creation_notification_kind).to eq "email_creation_notification"
      end
      context "user email" do
        let(:new_owner) { user.email }
        let(:ownership) { Ownership.new(initial_owner_kind: initial_owner_kind, owner: new_owner, creation_notification_kind: "no_creation_notification") }
        it "sets the owner, assigned creation_notification" do
          expect(ownership.user).to eq user
          expect(ownership.external_id).to eq new_owner
          expect(ownership.creation_notification_kind).to eq "no_creation_notification"
        end
      end
    end
  end
end
