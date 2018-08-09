require_relative 'job'

class Clone < Job

  def inner_run
    DbOperations.clone_count_values_table(
      payload, 
      options_struct.old_selects, 
      options_struct.new_selects
    )
    completed('completed_at' => formatted_current_time)
  end
end
