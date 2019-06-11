# frozen_string_literal: true

class RegistrationLog < ApplicationRecord
  include Uuidable
  KIND_ENUM = {
    ownership_log: 0,
    appraisal_log: 1,
    service_record_log: 2,
    information_log: 3,
  }.freeze

  AUTHORIZER_ENUM = {
    authorizer_owner: 0,
    authorizer_bike_index: 1,
    authorizer_globalid: 2,
  }.freeze

  belongs_to :registration
  belongs_to :user
  belongs_to :ownership
  has_many :public_images, as: :imageable, dependent: :destroy

  enum kind: KIND_ENUM
  enum authorizer: AUTHORIZER_ENUM

  def kind_display
    kind&.gsub(/_log/, "")
  end
end
