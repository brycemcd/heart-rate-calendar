FactoryGirl.define do
  factory :user do
    provider "Fitbit"
    uid '1234'
    name 'Tom'
    refresh_token '1234abd'
    access_token '1234.abe.def'
    token_expires_at "1480344524"
  end
end
