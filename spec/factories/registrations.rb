# frozen_string_literal: true

FactoryBot.define do
  factory :registration do
    status { "registered" }
    factory :registration_with_current_owner do
      transient do
        user { FactoryBot.create(:user) }
        current_owner { user }
      end
      after(:create) do |registration, evaluator|
        FactoryBot.create(:ownership, registration: registration, user: evaluator.current_owner)
      end
    end
  end
end
