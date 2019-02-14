# frozen_string_literal: true

class Ownership < ApplicationRecord
  belongs_to :registration
  has_many :attestations
  belongs_to :user

  scope :current, -> { where.not(started_at: nil).where(ended_at: nil) }
  scope :previous, -> { where.not(ended_at: nil) }

  def self.create_for(registration, creator:, owner:)
    previous_ownership = registration.current_ownership
    ownership = create(registration: registration,
                       user: owner,
                       started_at: Time.now)
    Attestation.create(registration: registration,
                       user: creator.is_a?(User) ? creator : nil,
                       ownership: ownership,
                       authorizer: authorizer_for_creator(creator),
                       kind: "ownership")
    previous_ownership&.mark_no_longer_current
    ownership
  end

  def self.authorizer_for_creator(creator)
    if creator.is_a?(User)
      "authorizer_owner"
    elsif creator == "bike_index"
      "authorizer_bike_index"
    end
  end

  def current?; started_at.present? && ended_at.blank? end

  def previous?; started_at.present? && ended_at.present? end

  def authorizer; attestations.reorder(:id).first&.authorizer end

  # Eventually, we may want to add an attestation here too
  def mark_no_longer_current
    update_attributes(ended_at: Time.now)
  end
end
