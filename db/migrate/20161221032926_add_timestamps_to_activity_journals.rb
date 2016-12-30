class AddTimestampsToActivityJournals < ActiveRecord::Migration[5.0]
  def change
    change_table(:activity_journals) { |t| t.timestamps }
  end
end
