namespace :heart_rate_data do
  desc "Update Fitbit heart rate data for the last user"
  task sync: :environment do
    User.last.add_heart_rate_data!
  end
end
