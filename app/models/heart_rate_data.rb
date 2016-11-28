class HeartRateData < ApplicationRecord

  belongs_to :user, dependent: :destroy

  def update_heart_rate_data!
    client = Fitbit::Client.new(
      client_id: ENV['FITBIT_OAUTH_CLIENT_ID'],
      client_secret: ENV['FITBIT_OAUTH_CLIENT_SECRET'],
      access_token: user.access_token,
      refresh_token: user.refresh_token,
      expires_at: user.token_expires_at
    )

    self.data = client.heart_rate_intraday_time_series(user_id: '-', date: 'today', start_time: '00:00', end_date: '24:00', detail_level: '1min')
  end
end
