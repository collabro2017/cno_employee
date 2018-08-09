class BinaryString < String

  def self.build(max_position)
    total_bytes = ((max_position + 1) / 8.0).ceil
    str = 0.chr * total_bytes
    self.new(str)
  end

  def set_bit(position, bit_value=1)
    if [0,1].include? bit_value
      byte_position = position / 8
      bit_position = position % 8
      byte = Byte.new(self.getbyte(byte_position))
      byte.set_bit(bit_position, bit_value)
      self.setbyte(byte_position, byte.to_i)
    else
      raise ArgumentError, 'Bit value should be either 0 or 1'
    end
  end

  def each_slice_positions(slice_size)
    batches = []
    bitmap.each_byte.each_slice(slice_size).with_index do |slice, i|
      byte_offset = (slice_size * 8 * i) # in relation to the other slices

      positions = slice.map.with_index do |byte, j|
        bit_offset = byte_offset + (8 * j) # in relation to the other bytes
        byte_obj.value = byte
        byte_obj.on_bits.map { |position| position + bit_offset  }
      end
      batches << positions.flatten!
    end
    batches
  end

end
