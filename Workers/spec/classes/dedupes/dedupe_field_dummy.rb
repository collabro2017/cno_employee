class DedupeFieldDummy < Classes::Field
  def initialize(dedupe_struct, header_struct)
    @header_struct = header_struct
    super(dedupe_struct)
  end
end

