class CreateExternalRegistrations < ActiveRecord::Migration[5.2]
  def change
    create_table :external_registrations do |t|
      t.references :registration
      t.integer :provider
      t.string :external_id
      t.json :data

      t.timestamps
    end
  end
end
