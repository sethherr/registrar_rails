# frozen_string_literal: true

# This is a stub for now.
# We'll want to make it send notifications to admins when shit goes wrong though
# Once it happens and I get an error alert, I'll make it actually work
class NotifyAdminsJob < ApplicationJob
  VALID_KINDS = %w[]
  def perform(kind, data = {})
    raise "THIS WAS NEVER ACTUALLY SET UP TO SEND MAIL. #{kind} - #{data}"
  end
end
