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

  def manufacturer_tag
    return external_data && external_data["manufacturer_name"] if bike_index?
  end

  def main_category_tag
    return "Bicycle" if bike_index?
  end

  def title
    return external_data && external_data["title"] if bike_index?
  end

  def description
    return external_data && external_data["description"] if bike_index?
  end

  def update_registration
    registration.manufacturer_tag ||= manufacturer_tag if manufacturer_tag.present?
    registration.main_category_tag ||= main_category_tag if main_category_tag.present?
    registration.title ||= title if title.present?
    registration.description ||= description if description.present?
    registration&.update_attributes(updated_at: Time.now)
  end

  def status
    return "missing" if bike_index? && external_data && external_data["stolen"]
    "registered"
  end
end
