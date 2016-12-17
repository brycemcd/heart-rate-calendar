class RenameHeartRateDataToActivityJournal < ActiveRecord::Migration[5.0]
  def change
    rename_table :heart_rate_data, :activity_journals
  end
end
