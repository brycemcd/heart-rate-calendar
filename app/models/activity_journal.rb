class ActivityJournal < ApplicationRecord
  SUPPORTED_ACTIVITY_TYPE_HASH = {
    unknown: 'unknown',
    heart_rate: 'heart_rate',
    steps: 'steps',
  }

  belongs_to :user

  validates :activity_type, inclusion: { in: %w(heart_rate steps) }


  enum activity_type: SUPPORTED_ACTIVITY_TYPE_HASH

  def update_heart_rate_data!(date: 'today')
    update_record_with_data(:heart_rate_data_for_the_day, date, :heart_rate)
  end

  def update_step_count_data!(date: 'today')
    update_record_with_data(:step_data_for_the_day, date, :steps)
  end

  private

  # TODO: refactor many of these methods below into their own service object
  # passing around `date` everywhere is annoying and not properly factored

  def update_record_with_data(intraday_type, date, activity_type)
    return false unless valid_date?(date)
    data = self.send(intraday_type, date)
    return false unless data

    update!(data: data, activity_type: activity_type)
  end

  def step_data_for_the_day(date)
    client.activity_intraday_time_series(
      fitbit_intraday_default_hash(date).merge(resource_path: 'activities/steps')
    )
  end

  def heart_rate_data_for_the_day(date)
    client.heart_rate_intraday_time_series(
      fitbit_intraday_default_hash(date)
    )
  end

  def fitbit_intraday_default_hash(date)
    {
      base_date: date,
      date: date,
      detail_level: '1min',
      end_date: '1d',
      end_time: '23:59',
      start_time: '00:00',
      user_id: '-',
    }
  end

  def client
    Fitbit::Client.new(
      client_id: ENV['FITBIT_OAUTH_CLIENT_ID'],
      client_secret: ENV['FITBIT_OAUTH_CLIENT_SECRET'],
      access_token: user.access_token,
      refresh_token: user.refresh_token,
      expires_at: user.token_expires_at
    )
  end

  def valid_date?(date)
    return true if date == 'today'

    raise ArgumentError, 'invalid date' unless date =~ /\d{4}-\d{2}-\d{2}/
    Date.parse(date)
  end
end
