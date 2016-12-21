FactoryGirl.define do
  factory :activity_journal do
    user User.new
    activity_type :steps
  end
end
