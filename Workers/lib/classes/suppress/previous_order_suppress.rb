module Classes
  class PreviousOrderSuppress < Suppress
    using CoreExtensions

    def initialize(suppress_struct, header_struct)
      @header_struct = header_struct
      suppress_struct.define_singleton_method(:criteria) do
        suppress_struct.record_key
      end
      @suppress_struct = suppress_struct
    end

    def generate_and_set_suppression_key
      if @suppress_struct.datasource == @header_struct.datasource
        process_record_id_suppress
      else
        process_record_key_suppress
        cleanup
      end
    end

    private

      def process_record_id_suppress
        binary_result = DbOperations.get_suppress_record_ids_as_bit_string(
                          suppress_table_name,
                          @header_struct.total_records
                        )

        RedisOperations.set(suppress_result_key, binary_result)
      end

      def process_record_key_suppress
        get_selected_value_ids

        delegate_work_to_nodes
      end

      def suppress_base_info
        "#{@header_struct.domain}_order#{@suppress_struct.id}"
      end

      def suppress_table_name
        "#{suppress_base_info}_record_keys"
      end

      def central_suppress_value_ids_bit_string_key
        "#{suppress_base_info}_suppress_value_ids_bit_string"
      end

      def cleanup
        RedisOperations.del(central_suppress_value_ids_bit_string_key)
      end

      # Aliases ----------------------------------------------------------------
      def total_nodes;       Configuration.numbers['total_nodes'];           end
      def padding;           Configuration.numbers['padding'];               end
      def log;               Configuration.logger;                           end
  end
end
