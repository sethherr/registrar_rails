# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "email#{n}@globalidregistrar.net" }

    # We only want confirmed users for tests
    before(:create) { |user| user.skip_confirmation! }

    factory :user_admin do
      admin_role { "admin" }
    end

    factory :user_developer do
      admin_role { "developer" }
    end
  end
end
