require_relative '../field'
require_relative 'select_field'
require_relative '../job'

module Classes
  class HighCardSelectField < Field
    include SelectField
    include Job
    using CoreExtensions

    def initialize(select_struct, header_struct)
      @header_struct = header_struct
      super(select_struct)
    end

    def field_result_key
      high_cardinality_field_result_key
    end

    private

      def initialize_values_enumerator
        get_selected_value_ids
        delegate_work_to_nodes
        @values = [1].each
        cleanup
      end

      def get_selected_value_ids
        select_struct = @field_struct.to_h
        select_struct[:count_values_table_name] = field_values_table_name
        select_struct[:count_values_column_name] = field_values_column_name

        binary_result = DbOperations.get_selected_value_ids_as_bit_string(
                          select_struct.to_struct,
                          full_field_locus_values,
                          criteria,
                          @header_struct.total_records
                        )

        RedisOperations.set(
          central_selected_value_ids_bit_string_key, binary_result
        )
      end

      def delegate_work_to_nodes
        keys_hash = {
          "value_ids_key" => central_selected_value_ids_bit_string_key, 
          "result_key"    => high_cardinality_field_result_key
        }
        options = {
          header:           @header_struct.to_h.merge!(keys_hash),
          select:           @field_struct.to_h,
          full_field_locus: full_field_locus
        }
        ToNodesDelegator.new.enqueue(klass: 'SelectNode', options: options)
      end

      def central_selected_value_ids_bit_string_key
        "#{field_locus_in_job}_selected_value_ids_bit_string"
      end

      def field_locus_in_job
        field_id = @field_struct.field_id.pad(padding)
        "#{@header_struct.domain}_j#{@header_struct.job_id}_f#{field_id}"
      end

      def high_cardinality_field_result_key
        "#{job_key_prefix}:f#{@field_struct.field_id.pad(padding)}:hcfr"
      end

      def cleanup
        RedisOperations.del(central_selected_value_ids_bit_string_key)
      end

      # Aliases ----------------------------------------------------------------

      # Numbers
      def total_nodes;       Configuration.numbers['total_nodes'];           end
  end
end
