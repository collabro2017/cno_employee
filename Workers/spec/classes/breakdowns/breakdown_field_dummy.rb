class BreakdownFieldDummy < Classes::Field
  include Classes::BreakdownField

  def initialize(breakdown_struct, header_struct, options: {})
    @header_struct = header_struct
    @filter_key = options[:filter_key]
    super(breakdown_struct)
  end
end

