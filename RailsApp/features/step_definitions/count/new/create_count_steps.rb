Given(/^I am on the counts homepage$/) do
  successful_sign_in
  visit counts_path
end

Then(/^it asks me for the name I want to give to the count$/) do
  page.should have_field "Name"
end

Then(/^it has a suggested name for a count entered by default$/) do 
  page.find_field("Name").value
    .should eq "#{Count.next_name_for('My New Count', current_user.id)}"
end

Then(/^it asks me to select the Data Source that I would like to use for that count$/) do
  page.should have_select "Datasource"
end

Given(/^a count named "(.*?)" does not exist for my user$/) do |count_name|
  Count.destroy_all(:name => count_name, user_id: current_user.id)
end

Given(/^there is already a count named "(.*?)"$/) do |count_name|
  new_count(count_name)
end

Given(/^I was shown the new count pane$/) do
  steps %{
    Given I am on the counts homepage
    When I click the "Create new" button
  }
end

Then(/^the count's name is "(.*?)"$/) do |name|
  page.should have_content(name)
end

Then(/^the count's datasource name is "(.*?)"$/) do |name|
  page.should have_content(name)
end

Given(/^there exists a Datasource named "(.*?)"$/) do |name|
  new_datasource(name)
end

Then(/^I am redirected to the count edit page for the newly created count$/) do
  page.should have_title("Edit Count")
end

Then(/^the message also presents one name suggestion in the form "(.*?)"\-\[number\]$/) do |name|
  page.should have_content("'#{Count.next_name_for(name, current_user.id)}'")
end

Then(/^the "(.*?)" field is highlighted because of an error$/) do |name|
  wrapper_div = page.find_field(name).first(:xpath,".//..")
  wrapper_div[:class].should =~ (/field_with_errors/)
end

Then(/^I am redirected to where I was$/) do
  # To-do: turn it into a generic step
  page.should have_title("All counts")
end
