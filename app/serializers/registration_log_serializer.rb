# frozen_string_literal: true

class RegistrationLogSerializer < ApplicationSerializer
  attributes :id, :created_at, :kind, :description, :authorizer

  def id
    object.to_param
  end

  def created_at
    object.created_at.to_i
  end

  def authorizer
    object.authorizer&.gsub("authorizer_", "")
  end
end
