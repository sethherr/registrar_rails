class CreateRegistrationTags < ActiveRecord::Migration[5.2]
  def change
    create_table :registration_tags do |t|
      t.references :registration, index: true
      t.references :tag, index: true

      t.timestamps
    end
  end
end
