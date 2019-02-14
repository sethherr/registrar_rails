# frozen_string_literal: true

FactoryBot.define do
  factory :external_registration do
    registration { FactoryBot.create(:registration) }
    factory :external_registration_bike_index do
      provider { "bike_index" }
      external_id { "432199" }
      external_data { File.read(Rails.root.join("spec", "fixtures", "bike_index_kona.json")) }
    end
  end
end
