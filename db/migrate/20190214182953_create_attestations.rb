class CreateAttestations < ActiveRecord::Migration[5.2]
  def change
    create_table :attestations do |t|
      t.references :registration, index: true
      t.references :user, index: true
      t.references :ownership, index: true
      t.integer :kind
      t.integer :authorizer

      t.timestamps
    end
  end
end
