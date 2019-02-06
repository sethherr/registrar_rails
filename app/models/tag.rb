# frozen_string_literal: true

class Tag < ApplicationRecord
  include Sluggable

  has_many :registration_tags
  has_many :registrations, through: :registration_tags
  belongs_to :parent, class_name: "Tag"
  has_many :children, class_name: "Tag", foreign_key: :parent_id

  before_validation :ensure_not_great_grandchild

  scope :main_category, -> { where(main_category: true) }
  scope :manufacturer, -> { where(manufacturer: true) }

  def self.friendly_find_or_create(str)
    return nil unless str.present?
    friendly_find(str) || create(name: str.strip)
  end

  def main_category?; main_category end

  def manufacturer?; manufacturer end

  def child?; parent_id.present? end

  def parent?; children.any? end

  def grandchild?; child? && parent.child? end

  def parent_tags
    Tag.where(id: [parent_id, parent&.parent_id])
  end

  def child_tags
    child_ids = children.pluck(:id)
    Tag.where(id: child_ids).or(Tag.where(parent_id: child_ids))
  end

  def ensure_not_great_grandchild
    raise "Can't create great grandchildren rn" if child? && parent.grandchild?
  end
end
