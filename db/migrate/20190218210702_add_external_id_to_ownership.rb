class AddExternalIdToOwnership < ActiveRecord::Migration[5.2]
  def change
    add_column :ownerships, :external_id, :string
    add_column :ownerships, :initial_owner_kind, :integer
    add_column :ownerships, :creation_notification_kind, :integer
  end
end
