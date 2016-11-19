Given(/^I am on the homepage$/) do
  visit('/')
end

When(/^sign in with FitBit$/) do
  click_on 'Sign in with FitBit'
end
