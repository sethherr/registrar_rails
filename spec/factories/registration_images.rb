# frozen_string_literal: true

FactoryBot.define do
  factory :registration_image do
    registration { FactoryBot.create(:registration) }
    external_image do
      {
        full: "https://files.bikeindex.org/uploads/Pu/48/2013-03-05_13.14.20.jpg",
        large: "https://files.bikeindex.org/uploads/Pu/48/large_2013-03-05_13.14.20.jpg",
        small: "https://files.bikeindex.org/uploads/Pu/48/small_2013-03-05_13.14.20.jpg"
      }
    end
    factory :registration_image_internal do
      external_image { {} }
      internal_image { File.open(File.join(Rails.root, "spec", "fixtures", "surly_image.jpg")) }
    end
  end
end
