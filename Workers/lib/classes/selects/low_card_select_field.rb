require_relative 'select_field'
require_relative '../low_card_field'

module Classes
  class LowCardSelectField < LowCardField
    include SelectField
    using CoreExtensions 

    def initialize(select_struct, header_struct)
      super(select_struct, header_struct)
    end

    private

      # Overwrite parent's method (called in the initializer)
      def initialize_values_enumerator
        @values = get_selected_values_ids.each
      end

      def get_selected_values_ids
        select_struct = @field_struct.to_h
        select_struct[:count_values_table_name] = field_values_table_name
        select_struct[:count_values_column_name] = field_values_column_name

        DbOperations.get_selected_value_ids(
          select_struct.to_struct, full_field_locus_values, criteria
        )
      end

  end
end