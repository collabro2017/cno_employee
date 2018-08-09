class InputMethodType < ClassyEnum::Base
  def is_default_lookup?
    false
  end
end

class InputMethodType::Binary < InputMethodType
  def icon
    'flag'
  end
end

class InputMethodType::EnterValue < InputMethodType
  def icon
    'keyboard-o'
  end
end

class InputMethodType::NumberRange < InputMethodType
  def icon
    'exchange'
  end
end

class InputMethodType::DateRange < InputMethodType
  def icon
    'calendar'
  end
end

class InputMethodType::Populated < InputMethodType
  def icon
    'minus'
  end
end

class InputMethodType::UploadFile < InputMethodType
  def icon
    'file-o'
  end
end

class InputMethodType::DefaultLookup < InputMethodType
  def is_default_lookup?
    true
  end

  def icon
    'check-square-o'
  end
end

# InputMethodType classes for lookups are generated dynamically
# So it is requiered that the module classes are loaded beforehand
Dir[Rails.root.join('app', 'models','lookups', 'custom','*.rb')].each do |file|
  require_dependency file
end

Lookups::Custom.constants.each do |type|
  class_name = "#{type.to_s.camelize}"
  
  klass = Class.new(InputMethodType) do
    def lookup_class_name
      "Lookups::Custom::#{self.class.name.demodulize}"
    end
  end
  InputMethodType.const_set "#{class_name}", klass
  InputMethodType.inherited(klass) #triggers inherited callback from parent
end
