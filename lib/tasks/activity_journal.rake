namespace :activity_journal do
  desc "Update Fitbit activity data for all users in the last n days"
  task :capture_last_n_days, [:n, :offset] => [:environment] do |t, args|
    offset = args[:offset].to_i
    offset = 1 if offset <= 0
    fail 'must set n to be an integer larger than 0' unless args[:n].to_i > 0

    User.where(provider: 'fitbit').each do |user|
      activities = [:steps, :heart_rate]

      # NOTE: this creates a need to move the Fitbit Client code out to its own class
      client = UserActivityJournalFetch.new(user: user, activity_type: :steps).client
      client.refresh!
      # the refresh token that was just updated need to be present in the 'user' object
      user = user.reload

      args[:n].to_i.downto(offset).each do |days_ago|

        d = (Date.today - days_ago).to_s

        activities.each do |activity|
          ajf = UserActivityJournalFetch.new(user: user,
                                             activity_type: activity,
                                             date: d)
          if ajf.create_journal_entry
            Rails.logger.info "[Journal Creation] Created #{activity} journal for #{d}"
          else
            Rails.logger.error "[Journal Creation] #{activity} journal for #{d} NOT created"
          end
        end
      end
    end
  end

  desc "Update Fitbit activity data for all users in the last 5 days"
  task capture_last_5_days: :environment do
    Rake::Task["activity_journal:capture_last_n_days"].invoke(5)
  end
end
