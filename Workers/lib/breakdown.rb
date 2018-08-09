require_relative 'job'

class Breakdown < Job

  MAX_LINES = 300
  HIGH_CARDINALITY_LIMIT = 1_000_000     # Totally arbitrary number but keeping
                                         # in mind that each key (one key per 
                                         # distinct value) uses ~30 MB in a 
                                         # 300MM record file.

  attr_reader :count_total, :count_result_key

  def inner_run
    run_total_count

    @count_result_key = if options_struct.dedupes.empty?
                          payload.simple_count_result_key
                        else
                          payload.deduped_count_result_key
                        end

    @count_total = RedisOperations.bitcount(count_result_key)

    DbOperations.drop_and_create_breakdown_results_table(
      payload,
      options_struct.breakdowns,
      options_struct.active_selects
    )

    run_breakdown_count unless @count_total.zero?

    completed(
      'result'       => count_total,
      'completed_at' => formatted_current_time
    )
  end

  private
    def run_breakdown_count
      log.info "Processing breakdown count"
      entry_point = Classes::Breakdown.build(
                      options_struct.breakdowns,
                      payload.header,
                      count_result_key
                    )

      table_values = []

      entry_point.each do |key, row|
        table_values << row
        RedisOperations.del(key)
      end

      DbOperations.insert_breakdown_results(payload, table_values)
    end

end
