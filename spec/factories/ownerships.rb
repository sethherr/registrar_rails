# frozen_string_literal: true

FactoryBot.define do
  factory :ownership do
    registration { FactoryBot.create(:registration) }
    user { FactoryBot.create(:user) }
    started_at { Time.now }
    after(:create) do |ownership, _evaluator|
      pp "fasdfsfsd"
      pp FactoryBot.create(:attestation_ownership, registration: ownership.registration,
                                                ownership: ownership,
                                                user: ownership.user)
    end
  end
end
