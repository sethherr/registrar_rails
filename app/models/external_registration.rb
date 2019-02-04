# frozen_string_literal: true

class ExternalRegistration < ApplicationRecord
  PROVIDER_ENUM = {
    globalid: 0,
    bike_index: 1
  }

  belongs_to :registration

  enum provider: PROVIDER_ENUM
end
