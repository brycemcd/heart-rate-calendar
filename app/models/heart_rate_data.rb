class HeartRateData < ApplicationRecord
  belongs_to :user, dependent: :destroy

  def update_heart_rate_data!(date: 'today')
    data = heart_rate_data_for_the_day(date)
    return false unless data

    update!(data: data)
  end

  private

  def heart_rate_data_for_the_day(date)
    return false unless valid_date?(date)

    client.heart_rate_intraday_time_series(
      user_id: '-',
      date: date,
      start_time: '00:00',
      end_date: '24:00',
      detail_level: '1min'
    )
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
