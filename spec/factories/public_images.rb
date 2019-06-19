# frozen_string_literal: true

FactoryBot.define do
  factory :public_image do
    imageable { FactoryBot.create(:registration) }
    image { File.open(File.join(Rails.root, "spec", "fixtures", "surly_image.jpg")) }
  end
end
