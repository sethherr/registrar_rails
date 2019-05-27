# frozen_string_literal: true

class PublicImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  PLACEHOLDER_URL = "https://files.bikeindex.org/blank.png"

  after :remove, :delete_empty_upstream_dirs

  def delete_empty_upstream_dirs
    path = ::File.expand_path(store_dir, root)
    Dir.delete(path) # fails if path not empty dir

    path = ::File.expand_path(base_store_dir, root)
    Dir.delete(path) # fails if path not empty dir
  rescue SystemCallError
    true # nothing, the dir is not empty
  end

  def store_dir
    "#{base_store_dir}/#{model.id}"
  end

  def base_store_dir
    "uploads/#{'test/' if Rails.env.test?}#{model.class.to_s[0, 2]}"
  end

  def extension_white_list
    %w[jpg jpeg gif png tiff tif]
  end

  # Fallback so the page doesn't break if the image isn't there
  def default_url
    PLACEHOLDER_URL
  end

  process :validate_dimensions
  process :fix_exif_rotation
  process :strip

  version :large do
    process resize_to_fit: [1200, 900]
  end

  version :small do
    process resize_to_fill: [300, 300]
  end
end
