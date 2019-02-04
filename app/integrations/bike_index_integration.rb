# frozen_string_literal: true

class BikeIndexIntegration
  # Using the "permanent bike creation token" - perhaps in the future we'll use individual user tokens for bike lookup
  # but for now, this is good enough
  PERMANENT_TOKEN = Rails.application.credentials.bike_index[:auth_token]

  def connection(api_token)
    Faraday.new(url: "https://bikeindex.org/") do |conn|
      conn.headers["Authorization"] = "Basic #{Base64.strict_encode64("#{api_token}:X")}"
      conn.headers["Content-Type"] = "application/json"
      conn.adapter Faraday.default_adapter
    end
  end

  def fetch_bike(bike_index_id)
    result = connection(PERMANENT_TOKEN).get("/api/v3/bikes/#{bike_index_id}")
    JSON.parse(result.body)["bike"]
  end
end
