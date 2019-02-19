# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do
  before { ActionMailer::Base.deliveries = [] }
  describe "new_ownership_notification" do
    let(:ownership) { FactoryBot.create(:ownership) }
    let(:mail) { ApplicationMailer.new_ownership_notification(ownership) }

    it "renders" do
      ownership.reload
      expect(mail.subject).to match(/registration/i)
      expect(mail.to).to eq([ownership.email])
      expect(mail.from).to eq(["support@globalidregistrar.net"])
      expect(mail.body.encoded).to match(/registrar/)
    end
  end
end
