# frozen_string_literal: true

module Sluggable
  extend ActiveSupport::Concern
  included do
    before_validation :set_slug
    validates :name, presence: true, uniqueness: true, if: :requires_name?
    validates :slug, uniqueness: true, if: :requires_name?
  end

  module ClassMethods
    def slugify(str)
      return nil unless str.present?
      str.to_s.gsub(/\([^\)]*\)/, "").strip
         .gsub(/(\s|\-|\+)+/, "_").downcase
         .gsub(/([^A-Za-z0-9_]+)/, "")
         .gsub(/_+/, "_")
    end

    def friendly_find_id(str)
      o = friendly_find(str)
      o.present? ? o.id : nil
    end

    def friendly_find_slug(str)
      find_by_slug(slugify(str))
    end

    def friendly_find(str)
      return nil unless str.present?
      integer_slug?(str) ? find(str) : friendly_find_slug(str)
    end

    def friendly_find!(str)
      friendly_find(str) || (raise ActiveRecord::RecordNotFound)
    end

    def integer_slug?(str)
      str.is_a?(Integer) || str.match(/\A\d*\z/).present?
    end
  end

  def set_slug
    self.slug = self.class.slugify(name)
  end

  # To make requiring name overrideable
  def requires_name?; true end

  # Because we generally want this
  def to_param; slug end
end
