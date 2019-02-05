# frozen_string_literal: true

class UpdateBikeIndexRegistrationJob < ApplicationJob
  def perform(bike_index_id)
    external_registration = ExternalRegistration.lookup_external_id("bike_index", bike_index_id)
    unless external_registration.present?
      external_registration = ExternalRegistration.create(registration: Registration.create,
                                                          provider: "bike_index",
                                                          external_id: bike_index_id)
    end
    external_registration.external_data = BikeIndexIntegration.new.fetch_bike(bike_index_id)
    external_registration.external_data_at = Time.now
    external_registration.save
    create_missing_photos(external_registration.registration,
                          external_registration.external_data["public_images"])
  end

  def create_missing_photos(registration, public_images)
    (public_images || []).each_with_index do |public_image, index|
      next if registration.registration_images.any? { |ri| ri.image_url == public_image["full"] }
      registration.registration_images.create(name: public_image["name"],
                                              listing_order: index,
                                              external_image: {
                                                full: public_image["full"],
                                                large: public_image["large"],
                                                small: public_image["thumb"]
                                              })
    end
  end
end
