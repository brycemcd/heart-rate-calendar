class AddTimestampsToActivityJournals < ActiveRecord::Migration[5.0]
  def change
    add_column :activity_journals, :created_at, :timestamp, null: false, default: '1900-01-01'
    add_column :activity_journals, :updated_at, :timestamp, null: false, default: '1900-01-01'
  end
end
