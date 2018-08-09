require 'murmurhash3'

  class Hasher

    def self.generate(*values)
      if values.count == 1
        first_value = values.first
        if first_value.is_a?(Hash)
          hash_array = MurmurHash3::V128.str_hash(
            first_value.sort.map(&:last).join(' ').squeeze(' ').strip.upcase
          )
        else
          hash_array = MurmurHash3::V128.str_hash(
            first_value.join(' ').squeeze(' ').strip.upcase
          )
        end
      else
        hash_array = MurmurHash3::V128.str_hash(
          values.join(' ').squeeze(' ').strip.upcase
        )
      end
      (hash_array[1] << 30) | (hash_array[0] >> 2)
      # Efficient version of: hash_array.pack('L*').unpack('Q').first >> 2
    end

  end

