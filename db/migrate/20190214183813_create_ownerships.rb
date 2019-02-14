class CreateOwnerships < ActiveRecord::Migration[5.2]
  def change
    create_table :ownerships do |t|
      t.references :registration, index: true
      t.references :user, index: true
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
