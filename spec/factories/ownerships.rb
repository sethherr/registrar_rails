# frozen_string_literal: true

FactoryBot.define do
  factory :ownership do
    registration { FactoryBot.create(:registration) }
    user { FactoryBot.create(:user) }
    started_at { Time.now }
    # Note: this is broken - it's totally worth fixing, not doing it rn though
    factory :ownership_with_attestation do
      after(:create) do |ownership, evaluator|
        FactoryBot.create(:attestation_ownership, registration: ownership.registration,
                                                  ownership: ownership,
                                                  user: evaluator.user)
      end
    end
  end
end
