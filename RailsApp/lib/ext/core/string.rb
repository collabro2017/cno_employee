class String

  if instance_methods.map(&:to_s).include?('to_bool')
    fail '#to_bool already defined on String'
  end

  def to_bool
    if self == true || self =~ (/(true|t|yes|y|1)$/i)
      true
    elsif self == false || self.blank? || self =~ (/(false|f|no|n|0)$/i)
      false
    else
      raise ArgumentError.new("invalid value for Boolean: '#{self}'")
    end
  end

end

