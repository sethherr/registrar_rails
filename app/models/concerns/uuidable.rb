# frozen_string_literal: true

module Uuidable
  extend ActiveSupport::Concern

  module ClassMethods
    def integer_id?(str)
      str.is_a?(Integer) || str.match(/\A\d*\z/).present?
    end

    def friendly_find(id_or_uuid)
      return nil unless id_or_uuid.present?
      integer_id?(id_or_uuid) ? find_by_id(id_or_uuid) : find_by_uuid(id_or_uuid)
    end
  end

  def to_param
    return uuid if uuid.present?
    # Because it's generated after creation, fallback to grab it
    # TODO: Make this less of a gross hack!
    self.uuid = self.class.where(id: id).pluck(:uuid).first
    # uuid
  end
end
