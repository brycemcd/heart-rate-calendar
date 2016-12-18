class User < ApplicationRecord
  has_many :activity_journals, dependent: :destroy

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      user.name = auth['info']['full_name']
      user.refresh_token = auth['credentials']['refresh_token']
      user.access_token = auth['credentials']['token']
      user.token_expires_at = auth['credentials']['expires_at']
    end
  end

  def add_heart_rate_data!(date: 'today')
    activity_journals << ActivityJournal.new(journal_date: date,
                                             activity_type: 'heart_rate')
    activity_journals.last.update_heart_rate_data!(date: date)
  end

  # notest
  def add_step_data!(date: 'today')
    activity_journals << ActivityJournal.new(journal_date: date,
                                             activity_type: 'steps')
    activity_journals.last.update_step_count_data!(date: date)
  end
end
