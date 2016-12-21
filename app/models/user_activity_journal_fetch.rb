class UserActivityJournalFetch
  attr_reader :user, :activity_type, :date, :valid, :errors, :api_response_data

  def initialize(user:, activity_type:, date: nil)
    @user = user
    @activity_type = activity_type
    @date = date || default_date
    reset_errors
  end

  # NOTE: there is a lot of validation logic in this class. It might be better
  # to move the validation logic out to it's own module
  # FIXME: if this is run after the data is fetched, there may have been an error
  # returned from the API but not registered here
  def valid?
    reset_errors
    valid_date?
    valid_user?
    valid_activity_type?
    self.errors.empty?
  end

  private def reset_errors
    @errors = []
  end

  def create_journal_entry
    return false unless valid?

    fetch_data if self.api_response_data.nil?

    user.activity_journals.create(
      activity_type: self.activity_type,
      journal_date: self.date,
      data: self.api_response_data.to_json,
    )
  end

  def fetch_data
    return false unless valid?

    begin
      response = api_call
      @api_response_data = response
    rescue JSON::ParserError => e
      @api_response_data = response
      self.errors << "api call returned invalid json: #{self.api_response_data}"
      return false
    end

    self.api_response_data
  end

  def api_response_valid?
    fetch_data if self.api_response_data.nil?

    if api_error_response?
      self.errors << "api call returned an error: #{self.api_response_data}"
      return false
    end

    if !return_data_valid?
      self.errors << "api call returned invalid data: #{self.api_response_data}"
      return false
    end

    true
  end

  private def api_call
    if self.activity_type == :steps
      step_data_for_the_day
    else
      heart_rate_data_for_the_day
    end
  end

  private def return_data_valid?
    if self.activity_type == :steps
      # NOTE: this is rife with potential errors
      self.api_response_data['activities-steps'].first['value'].to_i > 0
    else
      self.api_response_data['activities-heart-intraday']['dataset'].any?
    end
  end

  private def api_error_response?
    self.api_response_data.keys.include?('errors')
  end

  def step_data_for_the_day
    step_hash = fitbit_intraday_default_hash.merge(resource_path: 'activities/steps')
    self.client.activity_intraday_time_series(step_hash)
  end

  def heart_rate_data_for_the_day
    client.heart_rate_intraday_time_series(fitbit_intraday_default_hash)
  end

  # notest
  def fitbit_intraday_default_hash
    {
      base_date: self.date,
      date: self.date,
      detail_level: '1min',
      end_date: '1d',
      end_time: '23:59',
      start_time: '00:00',
      user_id: '-',
    }
  end

  def client
    Fitbit::Client.new(
      client_id: ENV['fitbit_oauth_client_id'],
      client_secret: ENV['fitbit_oauth_client_secret'],
      access_token: self.user.access_token,
      refresh_token: self.user.refresh_token,
      expires_at: self.user.token_expires_at
    )
  end

  def valid_date?
    begin
      Date.parse(self.date)
    rescue ArgumentError => e
      self.errors << "date `#{self.date}` is invalid"
      return false if e.message =~ /invalid date/
      fail e
    end
  end

  def valid_user?
    unless self.user.is_a?(User)
      self.errors << 'user is not a User object'
    end
  end

  def valid_activity_type?
    unless ActivityJournal::SUPPORTED_ACTIVITY_TYPE_HASH.keys.include?(self.activity_type)
      self.errors << 'activity type is not supported'
    end
  end

  private def default_date
    Date.today.to_s
  end
end
