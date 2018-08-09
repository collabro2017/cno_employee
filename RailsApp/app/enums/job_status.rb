class JobStatus < ClassyEnum::Base
  def self.active
    self.select(&:active?)
  end

  def active? #status may change without user intervention
    false
  end
end

class JobStatus::Created < JobStatus
end

class JobStatus::Queued < JobStatus
  def active?
    true
  end
end

class JobStatus::Working < JobStatus
  def active?
    true
  end
end

class JobStatus::Completed < JobStatus
end

class JobStatus::Failed < JobStatus
end

class JobStatus::Killed < JobStatus
end
