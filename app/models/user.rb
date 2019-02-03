# frozen_string_literal: true

class User < ActiveRecord::Base
  include ActiveModel::Dirty
  include PgSearch
  ADMIN_ROLE_ENUM = { not: 0, manager: 1, developer: 2 }.freeze

  devise :database_authenticatable, :registerable, :omniauthable, :confirmable,
         :recoverable, :rememberable, :trackable, omniauth_providers: [:bike_index]

  enum admin_role: ADMIN_ROLE_ENUM

  validates :email, uniqueness: { case_sensitive: false }

  before_validation :set_calculated_attributes

  scope :admin, -> { where.not(admin_role: "not") }

  def self.admin_roles; ADMIN_ROLE_ENUM.keys.map(&:to_s) end

  # Don't call this directly, use admin_search
  pg_search_scope :admin_search_scope, using: %i[tsearch dmetaphone], ignoring: :accents,
                                       against: %i[email name admin_search_field]
  # HACK: pg_search doesn't find phone numbers - so search for phone numbers if we don't find anything
  def self.admin_search(str)
    results = admin_search_scope(str)
    results.any? ? results : where("phone_number ILIKE ?", "%#{str.strip}%")
  end

  def self.from_omniauth(uid, auth)
    # user = where(bike_index_id: uid.to_i).first
    # user ||= where(email: auth.info.email).first
    # if user.present?
    #   # I remember rails issues where json fields weren't registering as changed
    #   # ... and therefor weren't updating. To play it safe, force updating auth
    #   # And force update email, skipping devise reconfirmation stuff
    #   user.update_columns(bike_index_auth: stored_bike_index_auth_hash(auth), email: auth.info.email)
    #   # Hopefully this only resaves the record if the value has changed...
    #   user.update_attributes(manually_confirm: true, bike_index_id: uid) unless user.bike_index_id.present?
    #   return user
    # end
    # User.create(bike_index_id: uid,
    #             email: auth.info.email,
    #             password: Devise.friendly_token[0, 20],
    #             name: auth.info.name,
    #             manually_confirm: true,
    #             bike_index_auth: stored_bike_index_auth_hash(auth))
  end

  def admin?; admin_role != "not" end

  def display_name; name.present? ? name : email end

  # Send devise emails in background, only in production because it's annoying in development
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later if Rails.env.production?
  end

  def manually_confirm=(val)
    return if confirmed?
    confirm if ActiveRecord::Type::Boolean.new.cast(val)
  end

  def set_calculated_attributes
    # To avoid having to search through json fields, just throw the relevant things into a new field
    self.admin_search_field = calculated_admin_search_field
  end

  private

  def calculated_admin_search_field
    "" # eventually will add more
  end
end
