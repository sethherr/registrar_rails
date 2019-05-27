# frozen_string_literal: true

class RegistrationSerializer < ApplicationSerializer
  attributes :id, :registered_at, :manufacturer, :main_category, :title, :description, :status, :tags_list, :images, :registration_logs

  def id
    object.to_param
  end

  def registered_at
    object.created_at.to_i
  end

  def manufacturer
    object.manufacturer_tag
  end

  def main_category
    object.main_category_tag
  end

  def registration_logs
    object.registration_logs.map do |registration_log|
      {
        recorded_at: registration_log.created_at.to_i,
        kind: registration_log.kind_display,
        title: registration_log.title,
        description: registration_log.description,
        authorizer: registration_log.authorizer&.gsub("authorizer_", "")
      }
    end
  end

  def images
    []
  end
end
