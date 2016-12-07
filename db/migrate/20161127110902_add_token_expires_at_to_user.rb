class AddTokenExpiresAtToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :token_expires_at, :string
  end
end
