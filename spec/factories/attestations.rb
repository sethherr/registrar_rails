# frozen_string_literal: true

FactoryBot.define do
  factory :attestation do
    registration { FactoryBot.create(:registration) }
    authorizer { "authorizer_owner" }
    user { registration&.current_owner || FactoryBot.create(:user) }
    factory :attestation_ownership do
      kind { "ownership_attestation" }
      ownership do
        FactoryBot.create(:ownership, registration: registration,
                                      user: user,
                                      skip_attestation: true)
      end
    end
    factory :attestation_information do
      kind { "information_attestation" }
    end
  end
end
