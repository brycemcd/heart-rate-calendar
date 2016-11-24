Given(/^I am on the homepage$/) do
  visit('/')
end

When(/^sign in with FitBit$/) do
  click_on 'Sign in with FitBit'
end

Then(/^I should be on the "([^"]*)"$/) do |arg1|
  expect(page).to have_content("You have successfully authenticated with Fitbit.")
end
