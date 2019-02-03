FactoryBot.define do
  factory :user_integration do
    user { FactoryBot.create(:user) }
    sequence(:external_id) { |n| "12#{n}" }
    auth_hash { {} }
    factory :user_integration_bike_index do
      provider { "bike_index" }
    end
  end
end
