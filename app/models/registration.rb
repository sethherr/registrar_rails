# frozen_string_literal: true

class Registration < ApplicationRecord
  STATUS_ENUM = {
    registered: 0,
    for_sale: 1,
    rented: 2,
    missing: 3,
    expired: 4
  }.freeze

  has_many :external_registrations

  enum status: STATUS_ENUM

  before_save :set_calculated_attributes

  def self.lookup_external_id(provider, id)
    ExternalRegistration.lookup_external_id(provider, id)&.registration
  end

  def set_calculated_attributes
    self.status = external_registrations.first.status if external_registrations.any?
  end
end
