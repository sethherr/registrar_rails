# frozen_string_literal: true

class Attestation < ApplicationRecord
  KIND_ENUM = {
    ownership_attestation: 0,
    appraisal_attestation: 1,
    service_record_attestation: 2,
    information_attestation: 3
  }.freeze

  AUTHORIZER_ENUM = {
    authorizer_owner: 0,
    authorizer_bike_index: 1,
    authorizer_globalid: 2
  }.freeze

  belongs_to :registration
  belongs_to :user
  belongs_to :ownership
  has_many :attestation_images, dependent: :destroy

  validates_presence_of :registration_id, :kind

  enum kind: KIND_ENUM
  enum authorizer: AUTHORIZER_ENUM
end
