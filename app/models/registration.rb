# frozen_string_literal: true

class Registration < ApplicationRecord
  STATUS_ENUM = {
    registered: 0,
    for_sale: 1,
    rented: 2,
    missing: 3,
    expired: 4
  }.freeze

  belongs_to :main_category, class_name: "Tag"
  belongs_to :manufacturer, class_name: "Tag"
  belongs_to :current_owner, class_name: "User"
  has_many :external_registrations, dependent: :destroy
  has_many :registration_images, dependent: :destroy
  has_many :registration_tags, dependent: :destroy
  has_many :tags, through: :registration_tags
  has_many :ownerships, dependent: :destroy
  has_many :attestations, dependent: :destroy
  accepts_nested_attributes_for :registration_tags, allow_destroy: true
  accepts_nested_attributes_for :registration_images, allow_destroy: true

  enum status: STATUS_ENUM

  before_save :set_calculated_attributes

  attr_accessor :new_owner, :new_owner_kind

  def self.statuses; STATUS_ENUM.keys.map(&:to_s) end

  def self.lookup_external_id(provider, id)
    ExternalRegistration.lookup_external_id(provider, id)&.registration
  end

  def self.integer_id?(str)
    str.is_a?(Integer) || str.match(/\A\d*\z/).present?
  end

  def self.friendly_find(id_or_uuid)
    return nil unless id_or_uuid.present?
    integer_id?(id_or_uuid) ? find_by_id(id_or_uuid) : find_by_uuid(id_or_uuid)
  end

  def to_param; uuid end

  def current_ownership; ownerships.current.reorder(:id).last end

  def current_owner_calculated; current_ownership&.user end

  def main_category_tag; main_category&.name end

  def manufacturer_tag; manufacturer&.name end

  def tags_list; tags.pluck(:name) end

  def manufacturer_tag=(val)
    self.manufacturer = Tag.friendly_find_or_create(val)
  end

  def main_category_tag=(val)
    self.main_category = Tag.friendly_find_or_create(val)
  end

  def tags_list=(val)
    (val.is_a?(Array) ? val : val.split(",")).each do |tag|
      registration_tags.build(tag: Tag.friendly_find_or_create(tag))
    end
  end

  def transfer_ownership(creator:, new_owner:, new_owner_kind:)
    raise "Unknown new ownership kind: #{new_owner_kind}" unless %w[user email globalid].include?(new_owner_kind)
    if new_owner_kind == "user"
      new_owner = new_owner.is_a?(User) ? new_owner : User.find(new_owner)
    end
    Ownership.create_for(self, creator: creator,
                               owner: new_owner,
                               initial_owner_kind: "initial_owner_#{new_owner_kind}")
  end

  def maker_title
    return nil if main_category_tag == "Pet"
    "Maker" # Could be author too
  end

  def set_calculated_attributes
    self.status = external_registrations.first.status if external_registrations.any?
    self.thumb_url = registration_images.listing_order.first&.image_url(:small)
    # Use registration tags here because they haven't been assigned yet. Laborious n+1 search because nothing else works
    self.manufacturer_id ||= registration_tags.select { |rt| rt.tag.manufacturer? }.first&.tag_id
    self.main_category_id ||= registration_tags.select { |rt| rt.tag.main_category? }.first&.tag_id
    current_owner_calculated_id = current_owner_calculated&.id
    self.current_owner_id = current_owner_calculated_id if current_owner_id != current_owner_calculated_id
  end
end
