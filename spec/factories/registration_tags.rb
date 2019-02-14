# frozen_string_literal: true

FactoryBot.define do
  factory :registration_tag do
    tag { FactoryBot.create(:tag) }
    registration { FactoryBot.create(:registration) }
  end
end
