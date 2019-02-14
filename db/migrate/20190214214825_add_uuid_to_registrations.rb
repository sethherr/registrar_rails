class AddUuidToRegistrations < ActiveRecord::Migration[5.2]
  def change
    add_column :registrations, :uuid, :uuid, default: 'uuid_generate_v4()'
  end
end
