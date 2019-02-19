# frozen_string_literal: true

# Preview all emails at /rails/mailers/application_mailer
class ApplicationMailerPreview < ActionMailer::Preview
  def new_ownership_notification
    ApplicationMailer.new_ownership_notification(find_ownership)
  end

  def reset_password_instructions
    ApplicationMailer.reset_password_instructions(find_user, "faketoken", {})
  end

  private

  def find_ownership
    Ownership.find(6)
  end

  def find_user
    User.last
  end
end
