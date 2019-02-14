# frozen_string_literal: true

FactoryBot.define do
  factory :attestation do
  end
  factory :attestation_ownership do
    transient do
      create_ownership { true }
    end
    kind { "ownership" }
    authorizer { "authorizer_owner" }
    user { FactoryBot.create(:user) }
    registration { FactoryBot.create(:registration) }
    # ownership { FactoryBot.create(:ownership, registration: registration, user: user) }
  end
end
