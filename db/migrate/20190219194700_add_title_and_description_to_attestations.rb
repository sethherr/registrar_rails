class AddTitleAndDescriptionToAttestations < ActiveRecord::Migration[5.2]
  def change
    add_column :attestations, :title, :string
    add_column :attestations, :description, :text
  end
end
