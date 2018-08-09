require 'securerandom'

require_relative 'decorated_payload'
require_relative 'redis_connection'

class RedisOperations

  OFF_VALUE, ON_VALUE = 1, 2
  DEFAULT_SLICE_SIZE = 8 * 1024 # size in bytes
  DEFAULT_EXPIRE_SECONDS = 3600 * 24 * 30 # 1 month in seconds

  class << self

    def complement(destination_key, source_key, total_records)
      transactional_op(destination_key) do |multi|
        multi.bitop('not', destination_key, source_key)
      end
      total_bits = redis.strlen(destination_key) * 8

      [0, *((total_records + 1)...total_bits)].each do |position|
        transactional_op(destination_key) do |multi|
          multi.setbit(destination_key, position, 0)
        end
      end
    end

    def intersect(destination_key, *source_keys)
      params = [destination_key, *source_keys]
      if redis.exists(destination_key)
        params = [destination_key, destination_key, *source_keys]
      end

      transactional_op(destination_key) { |multi| multi.bitop('and', *params) }
    end

    def unite(destination_key, *source_keys)
      transactional_op(destination_key) do |multi|
        multi.bitop('or', destination_key, destination_key, *source_keys)
      end
    end

    # Result is stored in the minuend
    def subtract(minuend, subtrahend, total_records)
      with_tmp_key do |tmp|
        complement(tmp, subtrahend, total_records)
        intersect(minuend, tmp)
      end
    end

    def load_bit_string # TO-DO: rename to load_field_value_bit_string
      key = payload.low_cardinality_field_bit_string_key

      unless redis.exists(key)
        field_is_binary = (payload.field.ui_data_type == 'binary')

        if field_is_binary && payload.value_id == OFF_VALUE
          on_key = payload.with_tmp_value_id(ON_VALUE) { load_bit_string }
          complement(key, on_key, payload.header.total_records)
        else
          bits = File.binread(payload.low_cardinality_field_bit_string_filename)
          set(key, bits)
        end
      end
      key
    end

    def get_bit_string(key)
      BinaryString.new(redis.get(key))
    end

    def get_sliced_bit_string(key, size: DEFAULT_SLICE_SIZE, &block)
      total = redis.strlen(key)
      x = 0
      while (x < total) do
        yield(BinaryString.new(redis.getrange(key, x, x + (size - 1))), x * 8)
        x += size
      end
    end

    def get_meaningful_bit_string(key)
      first = RedisOperations.first_on_byte(key)
      unless first.nil?
        redis.getrange(key, first, -1)
      end      
    end

    def first_on_byte(key)
      first = RedisOperations.first_on_bit(key)
      unless first.nil?
        (first / 8.0).floor
      end
    end

    def first_on_bit(key)
      pos = redis.bitpos(key, 1)
      pos >= 0 ? pos : nil
    end

    def turn_bit_on(key, position)
      redis.setbit(key, position, 1)
    end

    def turn_bit_off(key, position)
      redis.setbit(key, position, 0)
    end

    def with_tmp_key(&block)
      begin
        tmp_key = SecureRandom.urlsafe_base64(5)
        yield(tmp_key)
      ensure
        redis.del(tmp_key)
      end
    end

    def transactional_op(destination_key, &block)
      catch (:done)  do
        loop do
          transaction = redis.watch(destination_key) do
            redis.multi do |multi|
              yield(multi)
              redis.expire(destination_key, DEFAULT_EXPIRE_SECONDS)
            end
          end
          throw :done unless transaction.nil?
        end
      end
    end

    # Redis-RB methods
    def set(key, value, ex = DEFAULT_EXPIRE_SECONDS)
      redis.set(key, value, ex: ex)
    end

    def count(base_key, regexp: /.*/)
      list(base_key, regexp: regexp).count
    end

    def list(base_key, regexp: /.*/)
      redis.keys(base_key).sort.select { |key| !!(regexp =~ key) }
    end

    [:del, :bitcount, :exists, :strlen].each do |name|
      define_method(name) do |args|
        redis.send(name, args)
      end
    end

    private
      #Aliases
      def payload;           DecoratedPayload.instance;                      end
      def redis;             RedisConnection.connection;                     end
  end # class << self

end

