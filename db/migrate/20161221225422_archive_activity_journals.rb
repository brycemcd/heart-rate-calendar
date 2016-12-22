class ArchiveActivityJournals < ActiveRecord::Migration[5.0]
  def change
    add_column :activity_journals, :archived, :boolean, null: false, default: false
  end
end
