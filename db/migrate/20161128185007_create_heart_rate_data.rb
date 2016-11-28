class CreateHeartRateData < ActiveRecord::Migration[5.0]
  def change
    create_table :heart_rate_data do |t|
      t.json :data
    end
  end
end
