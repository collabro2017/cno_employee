Then(/^I can see a run breakdown button$/) do
  page.should have_css("div#run-breakdown-btn")
  page.should_not have_css("div#run-btn")
end

Given(/^there are breakdown fields selected$/) do
  breakdown_fields = page.all(:css, "#breakdown-tab .breakdown-header")
  breakdown_fields.count.should > 0
end

When(/^I click the breakdown button$/) do
	step "show me the page"
	click_button "breakdown-btn"
end

Then(/^I can see the results broken down by the fields$/) do
  page.should have_css(:css, "breakdown-table")
end

Given(/^there are no breakdown fields selected$/) do
  breakdown_fields = page.all(:css, "#breakdown-tab .breakdown-header")
  breakdown_fields.count.should be_zero
end
