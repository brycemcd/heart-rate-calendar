class AddDateAndActivityTypeToActivityJournals < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      CREATE TYPE activiy_journal_activity_type_enum AS ENUM ('unknown', 'heart_rate', 'steps')
    SQL
    add_column :activity_journals, :activity_type, :activiy_journal_activity_type_enum, null: false, default: 'unknown'
    add_column :activity_journals, :journal_date, :timestamp, null: false, default: '1900-01-01'

    ActivityJournal.update_all(activity_type: 'unknown',
                               journal_date: '1900-01-01')
  end

  def down
    remove_column :activity_journals, :activity_type
    remove_column :activity_journals, :journal_date

    execute <<-SQL
      DROP TYPE activiy_journal_activity_type_enum
    SQL
  end
end
