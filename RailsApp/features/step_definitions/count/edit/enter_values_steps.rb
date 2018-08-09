Given(/^the count has a select using an open field$/) do
  f1 = @current_count.datasource.fields.create!(name: "field1", description: "Desc Field1")
  cat = Category.create!(name: "Category1")
  cat.fields << f1
  cat.save!
  
  concrete_field = current_datasource.concrete_fields.first
  concrete_field.selectable = true
  concrete_field.open = true
  concrete_field.save!

  @current_count.add_search_condition(concrete_field)
  @current_count.save!
  
  unless current_path.blank?
    visit current_path # to reload the page
  end
end

Given(/^the count has a select using a field that isn't flagged as open$/) do
  steps %{
    Given the count has a select using an open field
  }
  concrete_field = current_datasource.concrete_fields.first
  concrete_field.open = false
  concrete_field.save!

  unless current_path.blank?
    visit current_path # to reload the page
  end
end

Then(/^I can see that the select has a tab for entering values$/) do
  groupId = current_datasource.concrete_fields.first.id
  page.should have_selector(".select-content[data-group-id='#{groupId}']")
  page.should have_selector("div##{groupId}-enter-values-tab")
end

Then(/^I can see that the select doesn't have a tab for entering values$/) do
  groupId = current_datasource.concrete_fields.first.id
  page.should have_selector(".select-content[data-group-id='#{groupId}']")
  page.should_not have_selector("div##{groupId}-enter-values-tab")
end

When(/^I enter (\d+) \(or more\) characters into the enter values textbox$/) do |chars|
  groupId = current_datasource.concrete_fields.first.id
  long_string = "A" * chars.to_i
  click_link "#{groupId}-enter-values-tab-link"
  fill_in "#{groupId}-enter-values-input", with: long_string
  pending "resolve strong parameters issues"
  #Fix: This passes if the ajax for saving the values is not called
  click_button "#{groupId}-enter-values-save" 
end

When(/^I enter some values$/) do
  groupId = current_datasource.concrete_fields.first.id
  click_link "#{groupId}-enter-values-tab-link"
  fill_in "#{groupId}-enter-values-input", with: "NY, \nCA,, \t\tTX; ;IL \n"
  pending "resolve strong parameters issues"
  click_button "#{groupId}-enter-values-save" 
end

Then(/^I should see those values added$/) do
  pending "resolve strong parameters issues"
  groupId = current_datasource.concrete_fields.first.id
  page.should have_field("#{groupId}-enter-values-input", with: "NY,CA,TX,IL")
end

Then(/^I should see SQL updated with the values too$/) do
  pending "resolve strong parameters issues"
  sql_tab_link = page.find("#count-sql>a")
  sql_tab_link.click
  sql_tab = page.find("#sql-tab")
  sql_tab.should have_text("'NY', 'CA', 'TX', 'IL'")
end

