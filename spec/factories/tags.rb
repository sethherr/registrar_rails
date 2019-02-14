# frozen_string_literal: true

FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "Tag - #{n}" }
    factory :tag_main do
      main_category { true }
    end
    factory :tag_manufacturer do
      manufacturer { true }
    end
  end
end
