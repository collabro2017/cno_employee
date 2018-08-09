require_relative '../../configuration'
require_relative '../../extensions/core_extensions'
require_relative '../job'

module Classes
  class Dedupe
    include Job
    using CoreExtensions

    def initialize(dedupe_struct, header_struct, simple_count_result_key)
      @dedupe_struct, @header_struct = dedupe_struct, header_struct
      @simple_count_result_key = simple_count_result_key
    end

    def run
      if field.is_a?(Classes::LowCardDedupeField)
        while field.move_to_next_value_id
          RedisOperations.with_tmp_key do |tmp_key|
            RedisOperations.intersect(
              tmp_key,
              @simple_count_result_key,
              field.current_value_key
            )

            first = RedisOperations.first_on_bit(tmp_key)
            unless first.nil?
              RedisOperations.with_tmp_key do |tmp_only_first|
                RedisOperations.turn_bit_on(tmp_only_first, first)
                RedisOperations.unite(deduped_count_result_key,tmp_only_first)
              end
            end
          end
        end
      else
        RedisOperations.unite(deduped_count_result_key,field.field_result_key)
        RedisOperations.del(field.field_result_key)
      end
    end

    def deduped_count_result_key
      "#{job_key_prefix}:dcr"
    end

    private
      def field
        return @field if defined?(@field)

        klass = case (type = @dedupe_struct.ui_data_type)
                when 'string', 'integer', 'date'
                  Classes::HighCardDedupeField
                when 'bitmap', 'binary'
                  Classes::LowCardDedupeField
                else
                  raise StandardError, "Unrecognized ui_data_type '#{type}'"
                end

        options = { simple_count_result_key: @simple_count_result_key }

        @field = klass.new(@dedupe_struct, @header_struct, options: options)
      end

      #Aliases
      def log;               Configuration.logger;                           end
    
  end
end
