class Fixnum
  def to_date
    Date.parse(self.to_s).strftime("%Y-%m-%d")
  end
end
