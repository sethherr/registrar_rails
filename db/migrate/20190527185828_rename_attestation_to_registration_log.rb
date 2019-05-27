class RenameAttestationToRegistrationLog < ActiveRecord::Migration[5.2]
  def change
    rename_table :attestations, :registration_logs
    rename_table :registration_images, :public_images
    drop_table :attestation_images
    remove_column :public_images, :registration_id
    add_reference :public_images, :imageable, polymorphic: true
  end
end
