class AddPrivateToPublicImages < ActiveRecord::Migration[5.2]
  def change
    add_column :public_images, :private_image, :boolean, default: false
  end
end
