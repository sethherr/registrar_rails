# frozen_string_literal: true

class PublicImage < ApplicationRecord
  include Uuidable
  belongs_to :imageable, polymorphic: true

  mount_uploader :internal_image, PublicImageUploader

  before_save :set_calculated_attributes
  after_commit :update_imageable

  attr_accessor :internal_image_cache

  scope :listing_order, -> { reorder(:listing_order) }

  def image_url(size = nil)
    size = "full" unless %w[full large small].include?(size.to_s)
    if internal_image.present?
      return size == "full" ? internal_image.url : internal_image.url(size)
    end
    return nil unless external_image.present?
    external_image.with_indifferent_access[size]
  end

  def set_calculated_attributes
    self.listing_order ||= imageable.public_images.maximum(:listing_order) || 0
    return true if name.present?
    self.name = image_url&.split("/")&.last&.split(".")&.first || "image"
  end

  def update_imageable
    imageable&.update_attributes(updated_at: Time.current)
  end
end
