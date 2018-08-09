When(/^I drag and drop a field name from the fields box to the count workspace$/) do
  pending
  draggable = find(:css, "div[id$=\"3-1-field\"]")
  droppable= find(:css, "div[id$=\"selects-tab\"]")
  draggable.drag_to(droppable)
end

Then(/^a copy of the field name gets added to the count work\-space$/) do
  pending
  page.should have_css(:css, "div[id$=\"1-3-field\"]")
  page.should have_css(:css, "div[id$=\"3-select\"]")
end

Then(/^the query gets updated$/) do
  pending
	click_link "sql-tab-link"
end

