# frozen_string_literal: true

# Just some notes for setting up the database.
# Not targeting actually making a legitimate seed file (for the time being)

# Create our initial parking location
parking_location = ParkingLocation.create(name: "SF Caltrain", address: "311 Townsend Street, San Francisco, CA 94107", latitude: 37.7765167, longitude: -122.3976116)
# And add some parking spots
10.times { parking_location.parking_spots.create!(kind: "unnamed_charging") }
