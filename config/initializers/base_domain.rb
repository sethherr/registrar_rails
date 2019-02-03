# frozen_string_literal: true

# For convenience, because it's something I expect
# TODO: do this in a more railsey way, not sure what that is
ENV["BASE_DOMAIN"] = Rails.env.production? ? "https://globalidregistrar.net" : "http://localhost:3009"
