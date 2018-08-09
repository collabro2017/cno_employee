require_relative '../field'

module Classes
  class HighCardBreakdownField < Field
    include BreakdownField

    def initialize(breakdown_struct, header_struct, options: {})
      @filter_key = options[:filter_key]
      @header_struct = header_struct
      super(breakdown_struct)
    end

    private

      def initialize_values_enumerator
        delegate_work_to_nodes
        @values = extract_value_ids_from_keys.sort.each
      end

      def delegate_work_to_nodes
        count = RedisOperations.count(key_wildcard, regexp: key_regexp)
        if count < @header_struct.max_rows
          ToNodesDelegator.new.enqueue(
            klass: 'BreakdownNode',
            options: {
              header:          @header_struct.to_h,
              breakdown:       @field_struct.to_h,
              conflict_values: @field_struct.conflict_values.to_h,
              filter_key:      @filter_key,
              key_wildcard:    key_wildcard,
              max_ids:         @header_struct.max_rows - count
            }
          )
        end
      end

      def extract_value_ids_from_keys
        RedisOperations.list(key_wildcard, regexp: key_regexp).map do |key|
          values = key.scan(/v\d+/)
          values.last.gsub('v','').to_i if values.any?
        end
      end

      def key_wildcard
        pbdr_key_for(1).gsub("v001#{PBDR_KEY_SUFFIX}", "v*#{PBDR_KEY_SUFFIX}")
      end

      def key_regexp
        /#{Regexp.escape(key_wildcard).gsub('\\*', '\d+')}/
      end

      # Aliases ----------------------------------------------------------------

      # Numbers
      def total_nodes;       Configuration.numbers['total_nodes'];           end
  end
end
