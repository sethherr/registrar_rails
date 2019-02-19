# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendOwnershipCreationNotificationJob do
  let(:subject) { SendOwnershipCreationNotificationJob }
  let(:instance) { subject.new }
  before { ActionMailer::Base.deliveries = [] }

  describe "perform" do
    context "no notification" do
      let(:ownership) { FactoryBot.create(:ownership, creation_notification_kind: "no_creation_notification") }
      it "noops" do
        ownership.reload
        expect(ownership.no_creation_notification?).to be_truthy
        instance.perform(ownership.id)
        expect(ActionMailer::Base.deliveries.empty?).to be_truthy
      end
    end
    context "email notification" do
      let(:ownership) { FactoryBot.create(:ownership, creation_notification_kind: "email_creation_notification") }
      it "adds to mailer" do
        ownership.reload
        instance.perform(ownership.id)
        expect(ActionMailer::Base.deliveries.empty?).to be_falsey
      end
    end
  end
end
