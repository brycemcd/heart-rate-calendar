require 'digest/sha1'

class ActivityJournal < ApplicationRecord
  SUPPORTED_ACTIVITY_TYPE_HASH = {
    unknown: 'unknown',
    heart_rate: 'heart_rate',
    steps: 'steps',
  }

  belongs_to :user

  validates :activity_type, inclusion: { in: %w(heart_rate steps) }
  validates :data_hash, uniqueness: { scope: :user_id }

  enum activity_type: SUPPORTED_ACTIVITY_TYPE_HASH

  before_validation do
    self.data_hash = Digest::SHA1.hexdigest(self.data.to_s)
  end

  after_commit do
    archive_older_records_by_same_user
  end

  # NOTE: the intent here is to keep the old records for later analysis to see
  # HOW the records change over time. The assumption is that the records become
  # more complete and accurate over time. This approach will not scale well.
  private def archive_older_records_by_same_user
    self.class.
      where(user_id: self.user_id,
            journal_date: self.journal_date,
            activity_type: self.activity_type).
      where.not(id: self.id).
      update_all(archived: true)

  end
end
