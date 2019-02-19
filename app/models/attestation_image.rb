# frozen_string_literal: true

class AttestationImage < ApplicationRecord
  belongs_to :attestation

  mount_uploader :image, RegistrationImageUploader

  before_save :set_calculated_attributes
  after_commit :update_attestation

  scope :listing_order, -> { reorder(:listing_order) }

  def set_calculated_attributes
    self.listing_order ||= attestation.attestation_images.maximum(:listing_order) || 0
    return true if name.present?
    self.name = image_url&.split("/")&.last&.split(".")&.first || "image"
  end

  def update_registration
    attestation&.update_attributes(updated_at: Time.now)
  end
end
