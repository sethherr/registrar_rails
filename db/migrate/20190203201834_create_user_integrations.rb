class CreateUserIntegrations < ActiveRecord::Migration[5.2]
  def change
    create_table :user_integrations do |t|
      t.references :user, index: true
      t.json :auth_hash
      t.integer :provider
      t.string :external_id
      t.timestamps
    end
  end
end
