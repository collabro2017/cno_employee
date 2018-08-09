require_relative '../configuration'
require_relative '../extensions/core_extensions'

module Classes
  class Field
    using CoreExtensions

    NAMESPACE = "sway"

    def initialize(field_struct)
      @field_struct = field_struct
      initialize_values_enumerator
    end

    def current_value_locus
      value_locus_for(@current_value_id)
    end

    def move_to_next_value_id
      begin
        @current_value_id = @values.next
        true
      rescue StopIteration
        false
      end
    end

    private

      %w[field_id distinct_count ui_data_type].each do |method_name|
        define_method(method_name.sub(/\Afield_/, '')) do
          @field_struct.public_send(method_name)
        end
      end

      def value_locus_for(value_id)
        if value_id.nil?
          raise(ArgumentError, 'Cannot determine locus for nil value_id')
        else
          "f#{padded_id}_v#{value_id.pad(padding)}"
        end
      end

      def padded_id
        @padded_id ||= id.pad(padding)
      end

      def initialize_values_enumerator
        @values = (1..distinct_count).each
      end


      # Aliases ----------------------------------------------------------------

      # Numbers
      def padding;           Configuration.numbers['padding'];               end

  end
end
