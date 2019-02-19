# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "support@globalidregistrar.net"
  layout "mailer"

  include Devise::Controllers::UrlHelpers
  include Devise::Mailers::Helpers

  def new_ownership_notification(ownership)
    @ownership = ownership
    @registration = @ownership.registration
    mail(subject: "Registration transfer: #{@registration.title}", to: @ownership.email)
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
