require_relative '../low_card_field'

module Classes
  class LowCardDedupeField < LowCardField

    def initialize(dedupe_struct, header_struct, options: {})
      super(dedupe_struct, header_struct)
    end

    private

      # Overwrite parent's method (called in the initializer)
      def initialize_values_enumerator
        @values = (1..distinct_count).each
      end

  end
end