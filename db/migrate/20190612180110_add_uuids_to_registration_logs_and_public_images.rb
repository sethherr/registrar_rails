class AddUuidsToRegistrationLogsAndPublicImages < ActiveRecord::Migration[5.2]
  def change
    # Enable the new uuid extension
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    add_column :registration_logs, :uuid, :uuid, default: "gen_random_uuid()"
    add_column :public_images, :uuid, :uuid, default: "gen_random_uuid()"
    # Also switch the other uuid to use the new uuid method
    change_column_default :registrations, :uuid, from: "uuid_generate_v4()", to: "gen_random_uuid()"
  end
end
