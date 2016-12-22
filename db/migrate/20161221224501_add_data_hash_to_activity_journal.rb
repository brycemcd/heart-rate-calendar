class AddDataHashToActivityJournal < ActiveRecord::Migration[5.0]
  def change
    add_column :activity_journals, :data_hash, :string, null: false
    add_index :activity_journals, [:data_hash, :user_id], unique: true
  end
end
