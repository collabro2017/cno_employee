Then(/^I can see the "(.*?)" (.*?)$/) do |name, container_type|
  # Examples of container types: "pane", "accordion"
  name = name.split.join('-').downcase
  page.should have_selector("div\##{name}-#{container_type}")
end

When(/^I click the "(.*?)" button$/) do |button|
  click_button button
end

When(/^I enter "(.*?)" in the "(.*?)" field$/) do |value, field|
  fill_in field, with: value
end

When(/^I select the "(.*?)" from  "(.*?)"$/) do |selection, dropdown|
  page.find(:select, dropdown).select selection
end

Then(/^I can see a message saying "(.*?)"$/) do |message|
  page.should have_content(message)
end

When(/^I click the "(.*?)" link$/) do |text|
  click_link text
end

Then(/^show me the page$/) do
  puts page.html
  save_and_open_page
end
