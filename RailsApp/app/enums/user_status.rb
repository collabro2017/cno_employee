class UserStatus < ClassyEnum::Base

  def status
    self.to_s
  end

  def status_for_display
    status.titleize
  end
end

class UserStatus::Active < UserStatus
end

class UserStatus::Blocked < UserStatus
end

class UserStatus::Pending < UserStatus
end
