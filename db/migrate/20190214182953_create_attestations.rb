class CreateAttestations < ActiveRecord::Migration[5.2]
  def change
    create_table :attestations do |t|
      t.references :registration
      t.references :user
      t.references :ownership
      t.integer :kind
      t.integer :authorizer

      t.timestamps
    end
  end
end
