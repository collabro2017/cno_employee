require_relative '../../configuration'
require_relative '../../extensions/core_extensions'

module Classes
  class Suppress
    using CoreExtensions

    def self.build(suppress_structs, header_struct, type)
      suppress_structs.map do |suppress_struct|
        klass = case type
                when 'order'
                  Classes::PreviousOrderSuppress
                when 'file'
                  Classes::FileSuppress
                else
                  raise StandardError, "Unrecognized suppress type '#{type}'"
                end

        klass.new(suppress_struct, header_struct)
      end
    end

    def run(simple_count_result_key)
      log.info "Processing #{self.class.name} suppress"

      generate_and_set_suppression_key

      RedisOperations.subtract(
          simple_count_result_key,
          suppress_result_key,
          @header_struct.total_records
        )

      RedisOperations.del(suppress_result_key)
    end

    def suppress_result_key
      field_id = @suppress_struct.criteria[:field_id]
      "#{suppress_base_info}:f#{field_id.pad(padding)}:hcsr"
    end

    def generate_and_set_suppresion_key
      raise NotImplementedError
    end

    private

      def get_selected_value_ids
        binary_result = DbOperations.get_suppress_value_ids_as_bit_string(
                          suppress_table_name,
                          @suppress_struct.criteria[:field_name],
                          @header_struct.total_records,
                          full_field_value_locus
                        )

        RedisOperations.set(
          central_suppress_value_ids_bit_string_key, binary_result
        )
      end

      def delegate_work_to_nodes
        keys_hash = {
          "value_ids_key" => central_suppress_value_ids_bit_string_key, 
          "result_key" => suppress_result_key
        }
        options = {
          header: @header_struct.to_h.merge!(keys_hash),
          suppress: @suppress_struct.criteria.to_h,
          full_field_locus: full_field_locus
        }
        ToNodesDelegator.new.enqueue(klass: 'SuppressNode', options: options)
      end

      def full_field_locus
        field_id = @suppress_struct.criteria[:field_id]
        "#{@header_struct.datasource}_f#{field_id.pad(padding)}"
      end

      def full_field_value_locus
        "#{full_field_locus}_values"
      end

      #Aliases
      def log;               Configuration.logger;                           end
    
  end
end
