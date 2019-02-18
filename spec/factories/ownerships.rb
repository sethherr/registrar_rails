# frozen_string_literal: true

FactoryBot.define do
  factory :ownership do
    transient do
      skip_attestation { false }
    end
    registration { FactoryBot.create(:registration) }
    user { FactoryBot.create(:user) }
    started_at { Time.now }
    after(:create) do |ownership, evaluator|
      unless evaluator.skip_attestation
        FactoryBot.create(:attestation_ownership, registration: ownership.registration,
                                                  ownership: ownership,
                                                  user: ownership.user)
      end
    end
  end
end
