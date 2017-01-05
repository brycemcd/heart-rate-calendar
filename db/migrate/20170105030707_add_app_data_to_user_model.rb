class AddAppDataToUserModel < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :fitbit_oauth_client_id, :string
    add_column :users, :fitbit_oauth_client_secret, :string
  end
end
