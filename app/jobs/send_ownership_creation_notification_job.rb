# frozen_string_literal: true

class SendOwnershipCreationNotificationJob < ApplicationJob
  def perform(ownership_id)
    ownership = Ownership.find(ownership_id)
    return true if ownership.no_creation_notification?
    ApplicationMailer.new_ownership_notification(ownership).deliver_now
  end
end
