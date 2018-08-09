class UiDataType < ClassyEnum::Base
  def can_link?
    false
  end
end

class UiDataType::Binary < UiDataType
  def can_link?
    true
  end
end

class UiDataType::Integer < UiDataType
end

class UiDataType::Float < UiDataType
end

class UiDataType::String < UiDataType
end

class UiDataType::Date < UiDataType
end

class UiDataType::Bitmap < UiDataType
end

class UiDataType::HighCardinality < UiDataType
end
