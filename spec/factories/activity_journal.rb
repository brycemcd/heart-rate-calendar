FactoryGirl.define do
  factory :activity_journal do
    user User.new
    activity_type :steps
    journal_date 3.days.ago
  end
end
