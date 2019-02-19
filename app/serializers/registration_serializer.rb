# frozen_string_literal: true

class RegistrationSerializer < ApplicationSerializer
  attributes :id, :registered_at, :manufacturer, :main_category, :title, :description, :status, :tags_list, :images, :attestations

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

  def attestations
    object.attestations.map do |attestation|
      {
        recorded_at: attestation.created_at.to_i,
        kind: attestation.kind_display,
        title: attestation.title,
        description: attestation.description,
        authorizer: attestation.authorizer&.gsub("authorizer_", "")
      }
    end
  end

  def images
    []
  end
end
