class ActivityJournal < ApplicationRecord
  SUPPORTED_ACTIVITY_TYPE_HASH = {
    unknown: 'unknown',
    heart_rate: 'heart_rate',
    steps: 'steps',
  }

  belongs_to :user

  validates :activity_type, inclusion: { in: %w(heart_rate steps) }


  enum activity_type: SUPPORTED_ACTIVITY_TYPE_HASH
end
