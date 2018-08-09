require 'csv'

File.open("consumer_data_out.csv", "w") do |ofile|
  CSV.foreach('consumer_data.csv', :headers => true) do |csv_obj|

    # header = Position,Field Name,Field Description,Selection,Category,Priority,Output,Notes,Length,Start,End

    std_name = csv_obj["Field Name"].gsub(/[-\/\+\(\),]/," ").strip.
        gsub(" ","_").downcase.squeeze("_").gsub("'","")[0..31]

    selection = csv_obj["Selection"]
    if selection == "Y" || selection == "S"
      csv_obj["Selection"] = true
    else
      csv_obj["Selection"] = false
    end

    category = csv_obj["Category"]

    if category.nil? || category.strip == ""
      csv_obj["Category"] = '["Uncategorized"]'
    elsif category == "People in hh?"
      csv_obj["Category"] = '["Uncategorized"]'
    elsif category == "HH / Financial"
      csv_obj["Category"] = "['HH','Financial']"
    else
      csv_obj["Category"] = "[\"#{csv_obj['Category']}\"]"
    end

    # puts csv_obj.fields.join("|")
    # puts csv_obj['Field Name']
    # puts "#{csv_obj['Field Name']}|#{csv_obj['Category']}|#{csv_obj['Selection']}"
    # puts "---"

    ofile.puts "#{std_name}|#{csv_obj['Field Name']}|#{csv_obj['Field Description']}|#{csv_obj['Category']}|#{csv_obj['Selection']}"
  end
end