class CreateExternalRegistrations < ActiveRecord::Migration[5.2]
  def change
    create_table :external_registrations do |t|
      t.references :registration
      t.integer :provider
      t.string :external_id
      t.json :external_data
      t.datetime :external_data_at

      t.timestamps
    end
  end
end
