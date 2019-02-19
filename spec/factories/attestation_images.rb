# frozen_string_literal: true

FactoryBot.define do
  factory :attestation_image do
    attestation { FactoryBot.create(:attestation_information) }
    image { File.open(File.join(Rails.root, "spec", "fixtures", "surly_image.jpg")) }
  end
end
