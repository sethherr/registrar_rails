# frozen_string_literal: true

FactoryBot.define do
  factory :ownership do
    transient do
      skip_registration_log { false }
    end
    registration { FactoryBot.create(:registration) }
    user { FactoryBot.create(:user) }
    started_at { Time.current }
    after(:create) do |ownership, evaluator|
      unless evaluator.skip_registration_log
        FactoryBot.create(:registration_log_ownership, registration: ownership.registration,
                                                       ownership: ownership,
                                                       user: ownership.user)
      end
    end
  end
end
