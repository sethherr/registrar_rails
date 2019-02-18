class AddExternalIdToOwnership < ActiveRecord::Migration[5.2]
  def change
    add_column :ownerships, :external_id, :string
    add_column :ownerships, :external_id_kind, :integer
  end
end
