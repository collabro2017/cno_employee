Given(/^I am the owner of a count$/) do 
  @current_count = new_count() # current_user is now part of the "world"
end

When(/^I go to the edit count page$/) do
  successful_sign_in # uses the current_user
  visit edit_count_path @current_count.id
end

Given(/^I am in the count edit page$/) do
  steps %{
    Given I am the owner of a count
    When I go to the edit count page
  }
end

Then(/^nothing happens$/) do
  pending # express the regexp above with the code you wish you had
end