# frozen_string_literal: true

class PublicImage < ApplicationRecord
  include Uuidable
  belongs_to :imageable, polymorphic: true

  mount_uploader :image, PublicImageUploader

  before_save :set_calculated_attributes
  after_commit :update_imageable

  scope :listing_order, -> { reorder(:listing_order) }
  scope :with_external_urls, -> { where.not(external_url: nil) }

  def self.matching_external_url(url)
    where(external_url: url)
  end

  def set_calculated_attributes
    self.external_url = remote_image_url if remote_image_url.present?
    self.listing_order ||= imageable.public_images.maximum(:listing_order) || 0
    return true if name.present?
    self.name = image_url&.split("/")&.last&.split(".")&.first || "image"
  end

  def update_imageable
    imageable&.update_attributes(updated_at: Time.current)
  end
end
