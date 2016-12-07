namespace :heart_rate_data do
  desc "Update Fitbit heart rate data for the last user"
  task sync: :environment do
    user = User.last
    user.heart_rate_datas << HeartRateData.new

    user.heart_rate_datas.last.update_heart_rate_data!
  end
end
