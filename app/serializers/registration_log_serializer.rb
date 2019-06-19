# frozen_string_literal: true

class RegistrationLogSerializer < ApplicationSerializer
  attributes :id, :created_at, :kind, :description, :authorizer

  def id
    object.to_param
  end

  def created_at
    object.created_at.to_i
  end

  def kind
    object.kind_display
  end

  def authorizer
    object.authorizer_display
  end
end
