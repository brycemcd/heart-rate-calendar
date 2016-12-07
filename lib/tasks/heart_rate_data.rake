namespace :heart_rate_data do
  desc "Update Fitbit heart rate data for the last user"
  task sync: :environment do
    user = User.last
    heart_rate_data = user.heart_rate_datas.first

    if heart_rate_data
      heart_rate_data.update_heart_rate_data!
    else
      user.heart_rate_datas << HeartRateData.new
      user.heart_rate_datas.first.update_heart_rate_data!
    end
  end
end
