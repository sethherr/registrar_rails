# frozen_string_literal: true

class Ownership < ApplicationRecord
  CREATION_NOTIFICATION_ENUM = {
    no_creation_notification: 0,
    email_creation_notification: 1,
  }.freeze
  INITIAL_OWNER_KIND_ENUM = {
    initial_owner_user: 0,
    initial_owner_email: 1,
    initial_owner_globalid: 2,
  }.freeze

  belongs_to :registration
  has_many :registration_logs
  belongs_to :user

  scope :current, -> { where.not(started_at: nil).where(ended_at: nil) }
  scope :previous, -> { where.not(ended_at: nil) }

  enum creation_notification_kind: CREATION_NOTIFICATION_ENUM
  enum initial_owner_kind: INITIAL_OWNER_KIND_ENUM

  after_commit :update_registration_and_send_notification

  # Use registration#transfer_ownership if ownership alread exists. Otherwise,
  # - always create ownerships through this method!
  def self.create_for(registration, creator:, owner:, initial_owner_kind: "initial_owner_user")
    previous_ownership = registration.current_ownership
    ownership = create(registration: registration,
                       initial_owner_kind: initial_owner_kind,
                       owner: owner,
                       started_at: Time.current)
    RegistrationLog.create(registration: registration,
                           user: creator.is_a?(User) ? creator : nil,
                           ownership: ownership,
                           authorizer: authorizer_for_creator(creator),
                           kind: "ownership_log")
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

  def authorizer; registration_logs.reorder(:id).first&.authorizer end

  def email
    @email ||= user&.email
    @email ||= initial_owner_email? ? external_id : nil
    @email
  end

  def owner=(val)
    if initial_owner_kind == "initial_owner_user"
      self.user = val
      self.creation_notification_kind ||= "no_creation_notification"
    else
      self.external_id = val
      if initial_owner_kind == "initial_owner_email"
        self.creation_notification_kind ||= "email_creation_notification"
        self.user = User.fuzzy_email_find(val)
      elsif initial_owner_kind == "globalid"
        self.creation_notification_kind ||= "no_creation_notification"
      end
    end
  end

  # Eventually, we may want to add an registration_log here too
  def mark_no_longer_current
    update_attributes(ended_at: Time.current)
  end

  def update_registration_and_send_notification
    registration&.update_attributes(updated_at: Time.current)
    # only send the notification if the id was changed - aka just was created
    SendOwnershipCreationNotificationJob.perform_async(id) if created_at == updated_at
  end
end
