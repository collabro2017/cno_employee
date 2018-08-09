require_relative 'rb_byte'

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
      byte = RbByte.new(self.getbyte(byte_position))
      byte.set_bit(bit_position, bit_value)
      self.setbyte(byte_position, byte.to_i)
    else
      raise ArgumentError, 'Bit value should be either 0 or 1'
    end
  end

  def positions_by_batch(batch_size, &block)
    positions = []
    self.each_byte.with_index.inject(0) do |total, (byte, i)|
      byte_on_bits(byte).each do |position|
        positions << position + (i * 8)
        total += 1

        if total > batch_size
          positions.clear
          break
        elsif total == batch_size
          if positions.any?
            yield positions
            positions.clear
          end
          total = 0
        end
      end
      
      total
    end

    yield positions if positions.any?
  end

  private
    def byte_on_bits(byte)
      @positions = {} unless defined?(@positions)
      if @positions[byte].nil?
        @positions[byte] = RbByte.new(byte).on_bits
      else
        @positions[byte]
      end
    end

end
