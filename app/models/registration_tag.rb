# frozen_string_literal: true

class RegistrationTag < ApplicationRecord
  belongs_to :registration
  belongs_to :tag

  validates_uniqueness_of :tag_id, scope: [:registration_id]

  scope :main_category, -> { left_joins(:tag).where("tag.main_category IS TRUE") }
  scope :manufacturer, -> { left_joins(:tag).where("tag.manufacturer IS TRUE") }
end
