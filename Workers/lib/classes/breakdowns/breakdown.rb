require 'forwardable'

require_relative '../../configuration'
require_relative '../../extensions/core_extensions'

module Classes
  class Breakdown
    using CoreExtensions

    include Enumerable

    NAMESPACE = 'sway'.freeze
    SUFFIX = 'pbdr'.freeze

    attr_accessor :previous

    def self.build(breakdown_structs, header_struct, count_result_key)
      breakdown_structs.each.inject(nil) do |previous, bd_struct|
        self.new(bd_struct, header_struct, previous, count_result_key)
      end
    end

    def initialize(breakdown_struct, header_struct, previous, count_result_key)
      @breakdown_struct, @header_struct = breakdown_struct, header_struct
      @previous = previous
      @count_result_key = count_result_key
    end

    def each
      count, sum = 0, 0
      while (row = get_next_row) && count < @header_struct.max_rows
        count += 1
        sum += row.last
        yield [field.current_pbdr_key, row]
      end

      if sum < count_total && row
        last_row = Array.new(row.size - 1) << (count_total - sum)
        yield [nil, last_row]
      end
    end

    def get_next_key
      unless field.nil?
        if field.move_to_next_value_id
          field.current_pbdr_key
        elsif previous && (new_filter = previous.get_next_key)
          field.reset_filter_key(new_filter)
          get_next_key
        end
      end
    end

    private

      def field
        return @field if defined?(@field)

        if (cached_filter_key = filter_key)
          klass = case (type = @breakdown_struct.ui_data_type)
                  when 'string', 'integer', 'date'
                    Classes::HighCardBreakdownField
                  when 'bitmap', 'binary'
                    Classes::LowCardBreakdownField
                  else
                    raise StandardError, "Unrecognized ui_data_type '#{type}'"
                  end

          @field = klass.new(
                     @breakdown_struct, @header_struct,
                     options: {filter_key: cached_filter_key}
                   )
        end
      end

      def get_next_row
        field.current_pbdr_row if get_next_key
      end

      def key_prefix
        domain = @header_struct.domain
        @key_prefix ||= "#{NAMESPACE}:#{domain}:j#{@header_struct.job_id}"
      end

      def filter_key
        previous.nil? ? @count_result_key : previous.get_next_key
      end

      def count_total
        @count_total ||= RedisOperations.bitcount(@count_result_key)
      end


      # Aliases ----------------------------------------------------------------

      # Numbers
      def padding;           Configuration.numbers['padding'];               end

  end
end

