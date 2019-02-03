# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do
  describe "test" do
    let(:user) { FactoryBot.create(:user) }
    let(:mail) { ApplicationMailer.test_email(user) }

    it "renders" do
      expect(mail.subject).to eq "test email"
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["support@globalidregistrar.net"])
      expect(mail.body.encoded).to match(/Test email/)
    end
  end
end
