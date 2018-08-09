class SuppressDummy < Classes::Suppress
  using CoreExtensions

  def initialize(suppress_struct, header_struct, type)
    @header_struct = header_struct
    if type == 'order'
      suppress_struct.define_singleton_method(:criteria) do
        suppress_struct.record_key
      end
    end
    @suppress_struct = suppress_struct
  end

  private

    def suppress_base_info
      "order#{@suppress_struct.id}"
    end

    def suppress_table_name
      "#{suppress_base_info}_record_keys"
    end

    def central_suppress_value_ids_bit_string_key
      "#{suppress_base_info}_suppress_value_ids_bit_string"
    end

    def padding;           Configuration.numbers['padding'];                 end
end

