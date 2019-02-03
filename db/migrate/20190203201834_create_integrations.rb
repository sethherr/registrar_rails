class CreateIntegrations < ActiveRecord::Migration[5.2]
  def change
    create_table :integrations do |t|
      t.references :user, index: true
      t.json :auth_hash
      t.string :provider
      t.string :external_id
      t.timestamps
    end
  end
end
