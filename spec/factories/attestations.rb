# frozen_string_literal: true

FactoryBot.define do
  factory :attestation do
    factory :attestation_ownership do
      kind { "ownership_attestation" }
      authorizer { "authorizer_owner" }
      user { FactoryBot.create(:user) }
      registration { FactoryBot.create(:registration) }
      ownership do
        FactoryBot.create(:ownership, registration: registration,
                                      user: user,
                                      skip_attestation: true)
      end
    end
  end
end
