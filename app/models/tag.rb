# frozen_string_literal: true

class Tag < ApplicationRecord
  include Sluggable

  has_many :registration_tags
  has_many :registrations, through: :registration_tags

  scope :main_category, -> { where(main_category: true) }
  scope :manufacturer, -> { where(manufacturer: true) }

  def self.friendly_find_or_create(str)
    return nil unless str.present?
    friendly_find(str) || create(name: str.strip)
  end

  def main_category?; main_category end

  def manufacturer?; manufacturer end
end
