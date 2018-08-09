module CountsHelper

  HUMAN_RESULT_THRESHOLD = 10_000_000

  def run_button_status(job)
    if job.present?
      job.active?
    end
  end

  def sortable(column, sort_column, sort_direction, title=nil)
  	title ||= column.titleize
    css_class = ''
    css_class = "current #{sort_direction}" if sort_column == column
  	link_to title, '#', id: column, class: css_class
  end

  def last_run_at(count)
    case count.most_recent_job_status
    when 'completed', 'failed', 'killed'
      human_date(count.most_recent_job_updated_at)
    when 'running'
      'Still running'
    else
      'Never been run'
    end
  end

  def tidy_result(result, human=false)
    ret = "No result yet"

    if result.present?
      if result < HUMAN_RESULT_THRESHOLD
        ret = result.to_s(:delimited)
      else
        ret = human ? result.to_s(:human) : result.to_s(:delimited)
      end
    end

    ret
  end

  def set_popover(name)
    data = {
      content: 'Coming Soon!',
      original_title: name,
      placement: 'right',
      trigger: 'hover',
      toggle: 'popover',
    }
    link_to name, nil, data: data
  end

  def status_caption(count)
    job = count.last_count_job
    job.present? ? job.status.to_s.titleize : 'Never been run'
  end

end
