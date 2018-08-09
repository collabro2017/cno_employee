require_relative 'job'
require_relative 'configuration'
require_relative 'redis_operations'
require_relative 'db_operations'
require_relative 'node_conflict_prone'

class DedupeNode < Job
  using CoreExtensions
  include NodeConflictProne

  def inner_run
    fill_record_ids_table
    conflicts = process_dedupe
    cleanup
    
    completed(
      'conflicts'    => conflicts,
      'completed_at' => Time.now.strftime("%F %T.%3N %z")
    )
  end

  private
    def payload
      @payload ||= DecoratedPayload.instance.tap do |pl|
                     pl.header  = options_struct.header
                     pl.field   = options_struct.dedupe
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

    def tmp_record_ids_table_name
      @tmp_record_ids_table_name ||=
        "#{options_struct.header.domain}_" + \
        "j#{options_struct.header.job_id}_" + \
        "f#{options_struct.dedupe.field_id.pad(padding)}" + \
        "_dedupe_record_ids_n#{node_id.pad(padding)}"
    end

    def fill_record_ids_table
      DbOperations.create_table(
        db_connection: DatabaseConnection['node_datastore'],
        table_name: tmp_record_ids_table_name,
        columns: {id: :int}
      )

      key = options_struct.header.simple_count_result_key
      RedisOperations.get_sliced_bit_string(key) do |bit_string, offset|

        RedisOperations.with_tmp_key do |tmp_key|
          RedisOperations.set(tmp_key, bit_string)
          meaningful_bit_string = 
            RedisOperations.get_meaningful_bit_string(tmp_key)
          unless meaningful_bit_string.nil?
            DbOperations.insert_in_dedupe_record_ids_table_from_binary_string(
               tmp_record_ids_table_name,
               meaningful_bit_string,
               offset + (RedisOperations.first_on_byte(tmp_key) * 8)
            )
          end
        end
      end
    end

    def process_dedupe
      conflicts = []
      binary_string = DbOperations.get_deduped_record_ids_as_bit_string(
                        tmp_record_ids_table_name,
                        node_field_table_name,
                        options_struct.header.total_records
                      ) do |row|
                        if local_value_id_conflicts.include?(row[:value_id])
                          conflicts << row
                        end 
                      end

      save_select_bit_string(binary_string)

      conflicts
    end

    def save_select_bit_string(binary_result)
      RedisOperations.with_tmp_key do |tmp_key|
        RedisOperations.set(tmp_key, binary_result)
        RedisOperations.unite(options_struct.header.result_key, tmp_key)
      end
    end

    def cleanup
      DbOperations.drop_deduped_values_ids_table(tmp_record_ids_table_name)
    end

    def node_field_table_name
      "#{options_struct.full_field_locus}_n#{node_id.pad(padding)}"
    end


    #Alias
    def log;               Configuration.logger;                             end
    def padding;           Configuration.numbers['padding'];                 end

end
