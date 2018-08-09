class AccessLevel < ClassyEnum::Base
  def access_level
    self.to_s
  end

  def access_level_for_display
    access_level.titleize
  end
end

class AccessLevel::Open < AccessLevel
end

class AccessLevel::Restricted < AccessLevel
end

class AccessLevel::Closed < AccessLevel
end
