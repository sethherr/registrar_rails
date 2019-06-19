# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ownership, type: :model do
  describe "factories" do
    # Because of the combination of ownership and registration_log, test factories create things correctly
    context "registration" do
      let(:registration) { FactoryBot.create(:registration_with_current_owner) }
      it "creates the associations correctly" do
        expect(registration.valid?).to be_truthy
        expect(registration.ownerships.count).to eq 1
        expect(registration.registration_logs.count).to eq 1
        expect(registration.current_ownership.registration_logs.count).to eq 1
        expect(registration.ownerships.first.registration_logs.first).to eq registration.registration_logs.first
      end
    end
    context "ownership" do
      let(:ownership) { FactoryBot.create(:ownership) }
      it "creates the associations correctly" do
        expect(ownership.valid?).to be_truthy
        expect(ownership.registration_logs.count).to eq 1
        registration_log = ownership.registration_logs.first
        expect(registration_log.kind).to eq "ownership_log"
        expect(ownership.registration).to be_present
        expect(registration_log.registration).to eq ownership.registration
        expect(registration_log.ownership).to eq ownership
        expect(registration_log.registration.ownerships.pluck(:id)).to eq([ownership.id])
        expect(ownership.registration.registration_logs.pluck(:id)).to eq([registration_log.id])
      end
    end
    context "registration_log" do
      let(:registration_log) { FactoryBot.create(:registration_log_ownership) }
      it "creates the associations correctly" do
        expect(registration_log.valid?).to be_truthy
        expect(registration_log.kind).to eq "ownership_log"
        expect(registration_log.ownership).to be_present
        expect(registration_log.registration).to be_present
        ownership = registration_log.ownership
        expect(ownership.registration_logs.pluck(:id)).to eq([registration_log.id])
        expect(registration_log.registration).to eq ownership.registration
        expect(registration_log.registration.ownerships.pluck(:id)).to eq([ownership.id])
        expect(ownership.registration.registration_logs.pluck(:id)).to eq([registration_log.id])
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
        expect(registration.registration_logs.count).to eq 1
        registration_log = registration.registration_logs.first
        expect(registration_log.user).to eq user
        expect(registration_log.ownership_log?).to be_truthy
        expect(registration_log.ownership).to eq ownership
        expect(user.registration_logs).to eq([registration_log])
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
          registration_log = new_ownership.registration_logs.last
          expect(registration_log.user).to eq user # Because it's the owner who sent it
          expect(registration_log.ownership_log?).to be_truthy
          expect(user.registration_logs.pluck(:id)).to eq([ownership.registration_logs.first.id, registration_log.id])
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
        expect(registration.registration_logs.count).to eq 1
        expect(ownership.creation_notification_kind).to eq "no_creation_notification"
        registration_log = registration.registration_logs.first
        expect(registration_log.authorizer).to eq "authorizer_bike_index"
        expect(registration_log.user).to be_nil
        expect(registration_log.ownership_log?).to be_truthy
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
        expect(ownership.email).to eq "party@stuff.com"
      end
      context "user email" do
        let(:new_owner) { user.email }
        let(:ownership) { Ownership.new(initial_owner_kind: initial_owner_kind, owner: new_owner, creation_notification_kind: "no_creation_notification") }
        it "sets the owner, assigned creation_notification" do
          expect(ownership.user).to eq user
          expect(ownership.external_id).to eq new_owner
          expect(ownership.creation_notification_kind).to eq "no_creation_notification"
          expect(ownership.email).to eq user.email
        end
      end
    end
  end
end
