class RenamePublicImagesImage < ActiveRecord::Migration[5.2]
  def change
    rename_column :public_images, :internal_image, :image
    remove_column :public_images, :external_image, :text
    remove_column :public_images, :private_image, :boolean
    add_column :public_images, :external_url, :text
  end
end
