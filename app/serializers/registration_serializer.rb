# frozen_string_literal: true

class RegistrationSerializer < ApplicationSerializer
  attributes :id, :registered_at, :manufacturer, :main_category, :title, :description, :status, :tags_list, :images, :logs

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

  def logs
    ActiveModel::ArraySerializer.new(object.registration_logs.order(id: :desc).limit(5),
                                     each_serializer: RegistrationLogSerializer,
                                     root: false).as_json
  end

  def images
    []
  end
end
