require_relative 'field'
require_relative '../extensions/core_extensions'

module Classes
  class LowCardField < Field
    using CoreExtensions

    SUFFIX = "lcfbs" # Low cardinality field bit string

    OFF_VALUE, ON_VALUE = 1, 2

    def initialize(field_struct, header_struct)
      @header_struct = header_struct
      super(field_struct)
    end

    # Datasource + field_id + id of current_value_id
    def full_current_value_locus
      full_value_locus_for(@current_value_id)
    end

    def current_value_key
      value_key_for(@current_value_id)
    end

    private

      %w[total_records datasource].each do |method_name|
        define_method(method_name) do
          @header_struct.public_send(method_name)
        end
      end

      # Datasource + field_id + value_id
      def full_value_locus_for(value_id)
        "#{datasource}_f#{padded_id}_v#{value_id.pad(padding)}"
      end

      def value_key_for(value_id)
        key = "#{NAMESPACE}:#{full_value_locus_for(value_id)}:#{SUFFIX}"

        unless RedisOperations.exists(key)
          if ui_data_type == 'binary' && value_id == OFF_VALUE
            on_key = value_key_for(ON_VALUE)
            RedisOperations.complement(key, on_key, total_records)
          else
            bits = File.binread(bit_string_filename_for(value_id))
            RedisOperations.set(key, bits)
          end
        end

        key
      end

      def bit_string_filename_for(value_id)
        File.join(bit_strings_dir, "#{full_value_locus_for(value_id)}.bin")
      end

      # Paths
      def bit_strings_dir;   Configuration.paths['bit_strings_dir'];         end

  end
end
