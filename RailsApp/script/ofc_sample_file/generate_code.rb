File.open("field_populator.rb", "w") do |ofile|

  File.open("consumer_data_out.csv", "r") do |file|

    file.each_line do |line|

      line = line.split('|')

      ofile.puts "f = Field.create(name: \"#{line[0]}\", caption: \"#{line[1].gsub('"',"'")}\", description: \"#{line[2].gsub('"',"'")}\")"
      
      cats = eval(line[3])
      cats.each do |cat|
        ofile.puts "cat = FieldCategory.find_or_create_by(name: \"#{cat}\")"
        ofile.puts "f.field_categories << cat"
      end
      ofile.puts "f.datasources_fields.create(datasource_id: datasources[0].id, filterable: \"#{line[4].strip}\")"

    end

  end

end