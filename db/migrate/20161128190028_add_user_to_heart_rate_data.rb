class AddUserToHeartRateData < ActiveRecord::Migration[5.0]
  def change
    add_reference :heart_rate_data, :user, foreign_key: true
  end
end
