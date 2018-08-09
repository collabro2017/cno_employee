module Classes
  module SelectField

    POSSIBLE_CRITERIA = [:values, :ranges, :blanks_criterion, :files]

    def full_field_locus
      "#{@header_struct.datasource}_f#{padded_id}"
    end

    def full_field_locus_values
      "#{full_field_locus}_values"
    end

    def linked_count_result_key
      namespace = Classes::Field::NAMESPACE
      "#{namespace}:#{@header_struct.domain}:j#{@header_struct.job_id}:lcr"
    end

    def field_values_table_name
      "#{@header_struct.domain}_count#{@header_struct.count_id}_values"
    end

    def field_values_column_name
      "#{@field_struct.db_data_type}_value"
    end

    #TO-DO: this method can be removes if we send the criteria array from RailsApp
    def criteria
      POSSIBLE_CRITERIA.select do |criterion|
        @field_struct.send("has_#{criterion}?")
      end
    end

  end
end

