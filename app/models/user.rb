# frozen_string_literal: true

class User < ActiveRecord::Base
  include ActiveModel::Dirty
  include PgSearch
  ADMIN_ROLE_ENUM = { not: 0, manager: 1, developer: 2 }.freeze

  devise :database_authenticatable, :registerable, :omniauthable, :confirmable,
         :recoverable, :rememberable, :trackable, omniauth_providers: [:bike_index]

  has_many :user_integrations

  enum admin_role: ADMIN_ROLE_ENUM

  validates :email, uniqueness: { case_sensitive: false }

  before_validation :set_calculated_attributes
  after_commit :update_external_registrations

  scope :admin, -> { where.not(admin_role: "not") }

  def self.admin_roles; ADMIN_ROLE_ENUM.keys.map(&:to_s) end

  # Don't call this directly, use admin_search
  pg_search_scope :admin_search_scope, ignoring: :accents,
                                       against: %i[email name admin_search_field]
  # HACK: pg_search doesn't find phone numbers - so search for phone numbers if we don't find anything
  def self.admin_search(str)
    results = admin_search_scope(str)
    results.any? ? results : where("phone_number ILIKE ?", "%#{str.strip}%")
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

  def integrated?(provider)
    user_integrations.where(provider: provider).any?
  end

  def bike_index_integration
    user_integrations.where(provider: "bike_index").first
  end

  def bike_index_bike_ids
    (bike_index_integration&.auth_hash&.dig("info") || {})["bike_ids"] || []
  end

  def set_calculated_attributes
    self.api_key ||= generate_api_key
    # To avoid having to search through json fields, just throw the relevant things into a new field
    self.admin_search_field = calculated_admin_search_field
  end

  def update_external_registrations
    bike_index_bike_ids.each { |i| UpdateBikeIndexRegistrationJob.perform_async(i) }
  end

  private

  # variable length, using two random things, probs ok?
  def generate_api_key
    unique_key = Devise.friendly_token + SecureRandom.random_number(10000).to_s
    return unique_key unless self.class.where(api_key: unique_key).any? { |i| i.id != id }
    generate_api_key # recall if it was a duplicate ;)
  end

  def calculated_admin_search_field
    "" # eventually will add more
  end
end
