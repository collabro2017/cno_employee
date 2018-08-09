require_relative 'job'

class Count < Job

  def inner_run
    run_total_count

    # TO-DO: This condition is duplicated in breakdown and order
    result_key = if options_struct.dedupes.empty?
                   payload.simple_count_result_key
                 else
                   payload.deduped_count_result_key
                 end

    completed(
      'result'       => RedisOperations.bitcount(result_key),
      'completed_at' => formatted_current_time
    )
  end

end
