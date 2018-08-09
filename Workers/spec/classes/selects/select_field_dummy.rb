class SelectFieldDummy < Classes::Field
  include Classes::SelectField
  
  def initialize(select_struct, header_struct)
    @header_struct = header_struct
    super(select_struct)
  end
end

