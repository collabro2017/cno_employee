require_relative '../../configuration'
require_relative '../../extensions/core_extensions'

module Classes
  class Select
    using CoreExtensions

    def initialize(select_struct, header_struct, simple_count_result_key)
      @select_struct, @header_struct = select_struct, header_struct
      @simple_count_result_key = simple_count_result_key
    end

    def run
      if field.is_a?(Classes::LowCardSelectField)
        RedisOperations.with_tmp_key do |tmp_key|
          while field.move_to_next_value_id
            RedisOperations.unite(tmp_key, field.current_value_key)
          end
          union_if_group(tmp_key)
        end
      else
        union_if_group(field.field_result_key)
        RedisOperations.del(field.field_result_key)
      end
    end

    private
      def field
        return @field if defined?(@field)

        klass = case (type = @select_struct.ui_data_type)
                when 'string', 'integer', 'date'
                  Classes::HighCardSelectField
                when 'bitmap', 'binary'
                  Classes::LowCardSelectField
                else
                  raise StandardError, "Unrecognized ui_data_type '#{type}'"
                end

        @field = klass.new(@select_struct, @header_struct)
      end

      def union_if_group(key)
        linked_key = field.linked_count_result_key
        if @select_struct.linked_to_next?
          RedisOperations.unite(linked_key, key)
          log.info "ORs result: #{RedisOperations.bitcount(linked_key)}"
        elsif RedisOperations.exists(linked_key)
          RedisOperations.unite(linked_key, key)
          log.info "ORs result: #{RedisOperations.bitcount(linked_key)}"
          intersect_or_subtract(linked_key)
          RedisOperations.del(linked_key)
        else
          intersect_or_subtract(key)
        end
      end

      def intersect_or_subtract(key)
        if @select_struct.exclude?
          RedisOperations.subtract(
            @simple_count_result_key,
            key,
            @header_struct.total_records
          )
        else
          RedisOperations.intersect(@simple_count_result_key, key)
        end
      end

      #Aliases
      def log;               Configuration.logger;                           end
    
  end
end
