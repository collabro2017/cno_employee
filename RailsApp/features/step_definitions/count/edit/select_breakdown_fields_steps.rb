Given(/^the count have fields flagged as breakdown$/) do
	cat = Category.create!(name: "Category1")
	cat.fields << @current_count.datasource.fields.create!(name: "field1", description: "Desc Field1")
	cat.fields << @current_count.datasource.fields.create!(name: "field2", description: "Desc Field2")
	cat.fields << @current_count.datasource.fields.create!(name: "field3", description: "Desc Field3")
	cat.fields << @current_count.datasource.fields.create!(name: "field4", description: "Desc Field4")
	cat.fields << @current_count.datasource.fields.create!(name: "field5", description: "Desc Field5")
	cat.fields << @current_count.datasource.fields.create!(name: "field6", description: "Desc Field6")

  cat.save!
  
	current_datasource.concrete_fields.each do |concrete_field|
    if concrete_field.id.odd?
      concrete_field.breakdown = true
    else
      concrete_field.breakdown = false
    end

    concrete_field.save!
  end
  
  unless current_path.blank?
    visit current_path # to reload the page
  end
end

When(/^I click the breakdown tab$/) do
  click_link "breakdown-tab-link"
end

Then(/^I can see the fields available for a breakdown count$/) do

  field_divs = page.all(:css, "#available-selects-pane .field")

  field_divs.each do |div|
  	div[:class].should include "breakdown"
  end

end

When(/^I drag a field and drop it into the breakdown pane$/) do
	draggable = find(:css, "div[id$=\"1-3-field\"]")
	draggable[:class].should include "breakdown"
	droppable = find(:css, "div[id$=\"breakdown-tab\"]")

  draggable.drag_to(droppable)
end

When(/^there are less than (\d+) fields already in$/) do |num|
	field_divs = page.all(:css, "#breakdown-tab .breakdown-header")
	field_divs.count.should be < num.to_i
end

Then(/^a copy of the field appears in the breakdown pane$/) do
  pending
  page.should have_css(:css, "div[id$=\"1-3-field\"]")
  page.should have_css(:css, "div[id$=\"3-breakdown\"]")
end

When(/^there are exactly (\d+) fields already in$/) do |num|
  draggable = find(:css, "div[id$=\"1-1-field\"]")
  draggable[:class].should include "breakdown"
  droppable = find(:css, "div[id$=\"breakdown-tab\"]")
  draggable.drag_to(droppable)

  draggable = find(:css, "div[id$=\"1-3-field\"]")
  draggable[:class].should include "breakdown"
  droppable = find(:css, "div[id$=\"breakdown-tab\"]")
  draggable.drag_to(droppable)

  draggable = find(:css, "div[id$=\"1-5-field\"]")
  draggable[:class].should include "breakdown"
  droppable = find(:css, "div[id$=\"breakdown-tab\"]")
  draggable.drag_to(droppable)
  pending
	page.should have(:css, "#breakdown-tab .breakdown-header", count: num.to_i)
end

When(/^the field is already in$/) do
	 pending
   page.should have_css(:css, "div[id$=\"3-breakdown\"]")
end