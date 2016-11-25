Rails.application.config.middleware.use OmniAuth::Builder do
  provider :fitbit,
           ENV['FITBIT_OAUTH_CLIENT_ID'],
           ENV['FITBIT_OAUTH_CLIENT_SECRET'],
           scope: 'profile heartrate', redirect_uri: ENV['FITBIT_CALLBACK_URL']
end
