class RenameTitleAndDescriptionForRegistrationLogs < ActiveRecord::Migration[5.2]
  def change
    remove_column :registration_logs, :title, :string
    rename_column :registration_logs, :description, :information
    add_column :registration_logs, :user_description, :text
  end
end
