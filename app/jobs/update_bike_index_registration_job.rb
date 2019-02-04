# frozen_string_literal: true

class UpdateBikeIndexRegistrationJob < ApplicationJob
  def perform(bike_index_id)
    external_registration = ExternalRegistration.lookup_external_id("bike_index", bike_index_id)
    unless external_registration.present?
      registration = Registration.create
      external_registration = ExternalRegistration.create(registration: registration,
                                                          provider: "bike_index",
                                                          external_id: bike_index_id)
    end
    external_registration.external_data = BikeIndexIntegration.new.fetch_bike(bike_index_id)
    external_registration.external_data_at = Time.now
    external_registration.save
  end
end
