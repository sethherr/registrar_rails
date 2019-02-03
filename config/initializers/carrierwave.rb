module CarrierWave
  module MiniMagick
    # check for images that are too large
    def validate_dimensions
      manipulate! do |img|
        if img.dimensions.any? { |i| i > 8000 }
          raise CarrierWave::ProcessingError, "Dimensions too large"
        end
        img
      end
    end

    # Rotates the image based on the EXIF Orientation
    def fix_exif_rotation
      manipulate! do |img|
        img.auto_orient
        img = yield(img) if block_given?
        img
      end
    end

    # Strips out all embedded information from the image
    def strip
      manipulate! do |img|
        img.strip
        img = yield(img) if block_given?
        img
      end
    end
  end
end

# Additional carrierwave configurations
CarrierWave.configure do |config|
  config.cache_dir = "#{Rails.root}/tmp/uploads"

  if Rails.env.production?
    config.fog_provider "fog/aws"
    config.asset_host = "https://files.globalidregistrar.net"
    config.fog_credentials = {
      provider: "AWS",
      aws_access_key_id: Rails.application.credentials.dig(:aws, :access_id),
      aws_secret_access_key: Rails.application.credentials.dig(:aws, :secret_key),
      region: "us-west-1"
    }
    config.fog_directory = Rails.application.credentials.dig(:aws, :bucket_name)
    config.fog_attributes = { "Cache-Control" => "max-age=315576000" }

    config.storage :fog
  else
    config.storage :file
  end
end
