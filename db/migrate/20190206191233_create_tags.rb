class CreateTags < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.string :name
      t.string :slug
      t.boolean :main_category
      t.boolean :manufacturer

      t.timestamps
    end
  end
end
