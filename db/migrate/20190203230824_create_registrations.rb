class CreateRegistrations < ActiveRecord::Migration[5.2]
  def change
    create_table :registrations do |t|
      t.string :thumb_url
      t.text :description
      t.integer :status, default: 0
      t.references :main_category, index: true
      t.references :manufacturer, index: true

      t.timestamps
    end
  end
end
