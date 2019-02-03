# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "support@globalidregistrar.net"
  layout "mailer"

  include Devise::Controllers::UrlHelpers
  include Devise::Mailers::Helpers

  def test_email(user)
    @user = user
    mail(subject: "test email", to: @user.email)
  end

  def confirmation_instructions(record, token, opts = {})
    @token = token
    devise_mail(record, :confirmation_instructions, opts)
  end

  def reset_password_instructions(record, token, opts = {})
    @token = token
    devise_mail(record, :reset_password_instructions, opts)
  end

  def email_changed(record, opts = {})
    devise_mail(record, :email_changed, opts)
  end

  def password_change(record, opts = {})
    devise_mail(record, :password_change, opts)
  end
end
