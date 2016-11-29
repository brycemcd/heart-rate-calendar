namespace :heart_rate_data do
  desc "Update heart rate data for each user for Fitbit"
  task sync: :environment do
    HeartRateData.all.each do |heart_rate_data|
      heart_rate_data.update_heart_rate_data!
    end
  end
end
