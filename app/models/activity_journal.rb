require 'digest/sha1'

class ActivityJournal < ApplicationRecord
  SUPPORTED_ACTIVITY_TYPE_HASH = {
    unknown: 'unknown',
    heart_rate: 'heart_rate',
    steps: 'steps',
  }

  belongs_to :user

  validates :activity_type, inclusion: { in: %w(heart_rate steps) }

  #before_validation :hash_data

  enum activity_type: SUPPORTED_ACTIVITY_TYPE_HASH

  before_validation do
    self.data_hash = Digest::SHA1.hexdigest(self.data)
  end
end
