class RbByte
  TOTAL_BITS = 8
  MAX_VALUE = 2 ** TOTAL_BITS

  attr_accessor :value

  def initialize(value=0)
    if !value.is_a?(Fixnum) || value > MAX_VALUE
      raise ArgumentError, "Maximum value allowed for RbByte #{MAX_VALUE}"
    else
      @value = value
    end
  end

  def set_bit(position, bit_value)
    if position > (TOTAL_BITS - 1)
      raise ArgumentError, "Maximum position allowed is #{TOTAL_BITS}"
    else
      if bit_value == 1
        turn_bit_on(position)
      else
        turn_bit_off(position)
      end
    end             
  end

  def on_bits
    TOTAL_BITS.times.select { |i| @value[(TOTAL_BITS - 1) - i] == 1 }
  end

  Fixnum.instance_methods.each do |method|
    define_method(method) { |args=nil| @value.send(method, *args) }
  end

  def method_missing(m, *args)
    @value.send(m, *args)
  end

  private
    def turn_bit_on(position)
      on_mask  = [128, 64, 32, 16, 8, 4, 2, 1]
      @value |= on_mask[position]
    end

    def turn_bit_off(position)
      off_mask = [127, 191, 223, 239, 247, 251, 253, 254]
      @value &= off_mask[position]
    end
end