
Given(/^The count's datasource has fields with categories$/) do
  cat = Category.create!(name: "Category1")
  f1 = @current_count.datasource.fields.create!(name: "field1", description: "Desc Field1")
  cat.fields << f1
  cat.fields << @current_count.datasource.fields.create!(name: "field2", description: "Desc Field2")
  cat.fields << @current_count.datasource.fields.create!(name: "field3", description: "Desc Field3")
  
  cat = Category.create!(name: "Category2")
  cat.fields << @current_count.datasource.fields.create!(name: "field4", description: "Desc Field4")
  cat.fields << @current_count.datasource.fields.create!(name: "field5", description: "Desc Field5")
  
  cat = Category.create!(name: "Category3")
  cat.fields << f1
  cat.fields << @current_count.datasource.fields.create!(name: "field6", description: "Desc Field6")
  cat.fields << @current_count.datasource.fields.create!(name: "field7", description: "Desc Field7")
  cat.fields << @current_count.datasource.fields.create!(name: "field8", description: "Desc Field8")

  current_datasource.concrete_fields.each do |concrete_field|
    if concrete_field.id.odd?
      concrete_field.selectable = true
    else
      concrete_field.selectable = false
    end

    if [1,3,5,8,13,21].include?(concrete_field.id)
      concrete_field.most_used = true
    else
      concrete_field.most_used = false
    end

    concrete_field.save
  end
  
  unless current_path.blank?
    visit current_path # to reload the page
  end

  
end

Then(/^the fields are grouped into the right category$/) do  
  fields = current_datasource.concrete_fields.selectable

  fields.each do |field|
  
    field_divs = page.all(:css, "div[id$=\"#{field[:id]}-field\"]")  
    
    found_in_category = false

    field_divs.each do |field_div|
      accordion_group_div = field_div.first(:xpath,".//..//..//..")
      field.categories.each do |category|
        if accordion_group_div[:id] == "#{category.id}-accordion-group"
          found_in_category = true
          break
        end
      end
    end

    found_in_category.should be(true)    
  end
end

Then(/^the most commonly used fields float up$/) do
  wrapper_div = page.find_by_id("0-accordion-group").first(:xpath,".//..")
  wrapper_div.first(:css, ".accordion-group")[:id].should eq "0-accordion-group"
end

Then(/^I can see all the datasource's selectable fields in there$/) do
  field_list = current_datasource.concrete_fields.selectable
  field_list.each do |field|
    page.should have_selector("div[id$=\"#{field[:id]}-field\"]") 
  end
end



When(/^I start typing in the fields search box$/) do
  page.should have_selector("input#textbox")
  keypress_script = "$('input#textbox').val('fIeLD1').keyup();"
  page.driver.execute_script(keypress_script)
end

Then(/^I can only see the fields that are the closest match to the text that I entered$/) do
  page.should have_no_selector("div[id$=\"2-5-field\"]") 
  page.should have_selector("div[id$=\"1-1-field\"]")
end

When(/^I hover over a field from the list$/) do
  #Assuming hovering
end

Then(/^I can see the field description$/) do
  fields = current_datasource.concrete_fields.selectable

  fields.each do |field|  
    field_divs = page.all(:css, "div[id$=\"-#{field[:id]}-field\"]")

    field_divs.each do |field_div|
      field_div[:title].should eq field.description
    end
  end 
end

##############################################
Then(/^Show me the world$/) do
  
  puts "*Current Count's DS: #{@current_count.datasource.name}"

  puts "Current DS: #{current_datasource.name}"

  Datasource.all.each do |ds|
    puts "DS: #{ds.name}"

    ds.fields.each do |f|
      puts "  Field: #{f.name}"

      f.categories.each do |cat|
        puts "    Category: #{cat.name}"
      end
    end

    puts "  ---"

    ds.filterable_fields.each do |f|
      puts "  F-Field: #{f.name}"
    end
  end
 
end
##############################################


