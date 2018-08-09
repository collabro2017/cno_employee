require_relative 'breakdown_field'

module Classes
  class LowCardBreakdownField < LowCardField
    include BreakdownField

    def initialize(breakdown_struct, header_struct, options: {})
      @filter_key = options[:filter_key]
      super(breakdown_struct, header_struct)
    end

    private

      # Overwrite parent's method (called in the initializer)
      def initialize_values_enumerator
        @values = apply_filter_key_to_value_ids.each
      end

      def apply_filter_key_to_value_ids
        (1..distinct_count).select { |value_id| set_pbdr_value_for(value_id) }
      end

      def set_pbdr_value_for(value_id)
        key = pbdr_key_for(value_id)
        RedisOperations.intersect(key, value_key_for(value_id), @filter_key)
        (zero = RedisOperations.bitcount(key).zero?) && RedisOperations.del(key)
        zero ? nil : key
      end

  end
end

