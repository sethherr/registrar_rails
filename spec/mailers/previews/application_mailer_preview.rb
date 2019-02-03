# frozen_string_literal: true

# Preview all emails at /rails/mailers/application_mailer
class ApplicationMailerPreview < ActionMailer::Preview
  def test_email
    ApplicationMailer.test_email(find_user)
  end

  def reset_password_instructions
    ApplicationMailer.reset_password_instructions(find_user, "faketoken", {})
  end

  private

  def find_user
    User.last
  end
end
