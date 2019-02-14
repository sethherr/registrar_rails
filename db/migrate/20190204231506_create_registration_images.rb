class CreateRegistrationImages < ActiveRecord::Migration[5.2]
  def change
    create_table :registration_images do |t|
      t.string :name
      t.references :registration, index: true
      t.text :internal_image
      t.json :external_image
      t.integer :listing_order

      t.timestamps
    end
  end
end
