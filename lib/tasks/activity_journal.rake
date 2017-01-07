namespace :activity_journal do
  desc "Update Fitbit heart rate data for all users"
  task capture_last_5_days: :environment do
    User.where(provider: 'fitbit').each do |user|
      activities = [:steps, :heart_rate]

      # NOTE: this creates a need to move the Fitbit Client code out to its own class
      client = UserActivityJournalFetch.new(user: user, activity_type: :steps).client
      client.refresh!
      # the refresh token that was just updated need to be present in the 'user' object
      user = user.reload

      5.downto(1).each do |days_ago|

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
end
