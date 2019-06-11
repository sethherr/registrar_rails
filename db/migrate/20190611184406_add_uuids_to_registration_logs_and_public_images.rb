class AddUuidsToRegistrationLogsAndPublicImages < ActiveRecord::Migration[5.2]
  def change
    add_column :registration_logs, :uuid, :uuid, default: "uuid_generate_v4()"
    add_column :public_images, :uuid, :uuid, default: "uuid_generate_v4()"
  end
end
