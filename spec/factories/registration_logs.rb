# frozen_string_literal: true

FactoryBot.define do
  factory :registration_log do
    registration { FactoryBot.create(:registration) }
    authorizer { "authorizer_owner" }
    user { registration&.current_owner || FactoryBot.create(:user) }
    factory :registration_log_ownership do
      kind { "ownership_log" }
      ownership do
        FactoryBot.create(:ownership, registration: registration,
                                      user: user,
                                      skip_registration_log: true)
      end
    end
    factory :registration_log_information do
      kind { "information_log" }
    end
  end
end
