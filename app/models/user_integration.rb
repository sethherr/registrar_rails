# frozen_string_literal: true

class UserIntegration < ApplicationRecord
  PROVIDER_ENUM = { globalid: 0, bike_index: 1 }.freeze

  belongs_to :user

  enum provider: PROVIDER_ENUM

  validates_presence_of :user_id

  after_commit :update_user

  def self.providers; PROVIDER_ENUM.keys.map(&:to_s) end

  def self.user_from_omniauth(authed_user_id, provider, uid, auth)
    raise "Unknown provider" unless providers.include?(provider)
    user ||= User.where(id: authed_user_id).first
    user_integration = where(provider: provider, external_id: uid).first || new(provider: provider, external_id: uid)
    user ||= user_integration&.user
    user ||= User.where(email: auth.info.email).first
    user.update_attributes(manually_confirm: true) if user.present? && !user.confirmed?
    user ||= User.create!(email: auth.info.email,
                          password: Devise.friendly_token[0, 20],
                          name: auth.info.name,
                          manually_confirm: true)
    # Update with the integration name if it's present and user doesn't have a name
    user.update_attribute :name, auth.info.name if user.name.blank? && auth.info.name.present?
    # Update the user_integration with the user_id if relevant
    user_integration.update_attributes(user_id: user.id, auth_hash: auth)
    user
  end

  def update_user
    user&.update_attributes(updated_at: Time.now)
  end
end
