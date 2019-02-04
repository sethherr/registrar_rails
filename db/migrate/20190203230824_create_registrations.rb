class CreateRegistrations < ActiveRecord::Migration[5.2]
  def change
    create_table :registrations do |t|
      t.text :description
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
