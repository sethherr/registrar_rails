class CreateAttestationImages < ActiveRecord::Migration[5.2]
  def change
    create_table :attestation_images do |t|
      t.string :name
      t.references :attestation, index: true
      t.text :image
      t.integer :listing_order


      t.timestamps
    end
  end
end
