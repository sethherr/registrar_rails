class AddCurrentOwnerIdToRegistrations < ActiveRecord::Migration[5.2]
  def change
    add_reference :registrations, :current_owner, index: true
  end
end
