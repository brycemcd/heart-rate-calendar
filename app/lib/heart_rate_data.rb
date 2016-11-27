class HeartRateData

  def self.update_heart_rate_data
    # TODO: for testing only
    current_user = User.first

    client = Fitbit::Client.new(
      client_id: ENV['FITBIT_OAUTH_CLIENT_ID'],
      client_secret: ENV['FITBIT_OAUTH_CLIENT_SECRET'],
      access_token: current_user.access_token,
      refresh_token: current_user.refresh_token,
      expires_at: current_user.token_expires_at
    )

    data = client.heart_rate_time_series(user_id: '-', date: 'today', period: '1m', base_date: 'today', end_date: nil)
    raise data.inspect
  end
end
