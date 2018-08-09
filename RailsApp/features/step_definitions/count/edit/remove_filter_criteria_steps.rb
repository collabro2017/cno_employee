Given(/^the count have fields already in use$/) do
	cf =  current_datasource.concrete_fields.first
	@current_count.add_search_condition(cf)
	@current_count.save

  visit current_path # to reload the page
end

When(/^I click the remove button$/) do
  pending "Solve strong parameters"
	click_link "remove-link-1"
	visit current_path
end

Then(/^the field get removed from the count$/) do
  page.should_not have_css("#remove-link-1")
end