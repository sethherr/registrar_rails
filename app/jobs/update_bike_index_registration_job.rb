# frozen_string_literal: true

class UpdateBikeIndexRegistrationJob < ApplicationJob
  def perform(bike_index_id, user_id = nil)
    external_registration = ExternalRegistration.lookup_external_id("bike_index", bike_index_id)
    unless external_registration.present?
      external_registration = ExternalRegistration.create(registration: Registration.create,
                                                          provider: "bike_index",
                                                          external_id: bike_index_id)
    end
    external_registration.external_data = BikeIndexIntegration.new.fetch_bike(bike_index_id)
    external_registration.external_data_at = Time.now
    external_registration.save
    update_registration_ownership(external_registration.registration, user_id)
    create_missing_photos(external_registration.registration,
                          external_registration.external_data["public_images"])
  end

  def update_registration_ownership(registration, user_id)
    user = user_id.present? && User.where(id: user_id).first
    return true if user.blank?
    return true if registration.current_owner == user
    Ownership.create_for(registration, creator: "bike_index", owner: user)
  end

  def create_missing_photos(registration, public_images)
    registration
    (public_images || []).each_with_index do |public_image, index|
      pp registration.public_images.listing_ordered
      next if registration.public_images.any? do |pi|
        pi.image_url == public_image["full"]
      end
      registration.public_images.create(name: public_image["name"],
                                              listing_order: index,
                                              external_image: {
                                                full: public_image["full"],
                                                large: public_image["large"],
                                                small: public_image["thumb"]
                                              })
    end
  end
end
