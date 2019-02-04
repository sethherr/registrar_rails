# frozen_string_literal: true

class ExternalRegistration < ApplicationRecord
  PROVIDER_ENUM = {
    globalid: 0,
    bike_index: 1
  }.freeze

  belongs_to :registration

  validates_presence_of :registration_id

  enum provider: PROVIDER_ENUM

  after_commit :update_registration

  def self.lookup_external_id(provider, id)
    where(provider: provider, external_id: id.to_s.strip).first
  end

  def update_registration
    registration&.update_attributes(updated_at: Time.now)
  end

  def status
    return "missing" if bike_index? && external_data && external_data["stolen"]
    "registered"
  end
end
