require_relative 'job'
require_relative 'extensions/core_extensions'
require_relative 'node_conflict_prone'

class BreakdownNode < Job
  include NodeConflictProne
  using CoreExtensions

  def inner_run
    fill_record_ids_table
    process_breakdown_record_ids_by_value_id
  ensure
    cleanup
  end

  private
    def payload
      @payload ||= DecoratedPayload.instance.tap do |pl|
                     pl.header  = options_struct.header
                     pl.field   = options_struct.breakdown
                     pl.node_id = node_id
                   end    
    end

    def node_id
      return @node_id if defined?(@node_id)

      if ENV['NODE_ID'].nil?
        raise ArgumentError.new('environment variable NODE_ID not found')
      else
        @node_id = ENV['NODE_ID'].to_i
      end
    end

    def filter_key
      @filter_key ||= options_struct.filter_key
    end

    def max_ids
      @max_ids ||= options_struct.max_ids
    end

    def tmp_record_ids_table_name
      @tmp_record_ids_table_name ||=
        "#{options_struct.header.domain}_" + \
        "j#{options_struct.header.job_id}_" + \
        "f#{options_struct.breakdown.field_id.pad(padding)}" + \
        "_bd_record_ids_n#{node_id.pad(padding)}"
    end

    def fill_record_ids_table
      DbOperations.create_table(
        db_connection: DatabaseConnection['node_datastore'],
        table_name: tmp_record_ids_table_name,
        columns: {id: :int}
      )

      RedisOperations.get_sliced_bit_string(filter_key) do |bit_string, offset|

        RedisOperations.with_tmp_key do |tmp_key|
          RedisOperations.set(tmp_key, bit_string)
          meaningful_bit_string = 
            RedisOperations.get_meaningful_bit_string(tmp_key)
          unless meaningful_bit_string.nil?
            DbOperations.insert_in_breakdown_record_ids_table_from_binary_string(
               tmp_record_ids_table_name,
               meaningful_bit_string,
               offset + (RedisOperations.first_on_byte(tmp_key) * 8)
            )
          end

        end
      end
    end

    def process_breakdown_record_ids_by_value_id
      data = DbOperations.breakdown_record_ids_by_value_id(payload)
      count = 0

      bit_string = BinaryString.build(options_struct.header.total_records)
      previous_value_id = nil

      data.paged_each(rows_per_fetch: batch_size) do |row|
        break if count == max_ids
        if ((row[:value_id] != previous_value_id) && !previous_value_id.nil?)
          save_breakdown_bit_string(bit_string, previous_value_id)
          count += 1
          bit_string = BinaryString.build(options_struct.header.total_records)
        end

        bit_string.set_bit(row[:id])
        previous_value_id = row[:value_id]
      end

      unless previous_value_id.nil?
        save_breakdown_bit_string(bit_string, previous_value_id)
      end
    end

    def save_breakdown_bit_string(bit_string, value_id)
      RedisOperations.with_tmp_key do |tmp_key|
        RedisOperations.set(tmp_key, bit_string)
        new_result_key = options_struct.key_wildcard.gsub(
                           'v*', "v#{value_id.pad(padding)}"
                         )
        if local_value_id_conflicts.include?(value_id)
          RedisOperations.unite(new_result_key, tmp_key)
        else
          RedisOperations.intersect(new_result_key, tmp_key, filter_key)
        end
      end
    end

    def cleanup
      DbOperations.node_drop_breakdown_record_ids_table(
        tmp_record_ids_table_name
      )
    end

    #Aliases
    def batch_size;        Configuration.numbers['batch_size'];            end
    def padding;           Configuration.numbers['padding'];               end

end
