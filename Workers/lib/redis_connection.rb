require 'resque'

class RedisConnection

  def self.connection
    return @@redis if defined?(@@redis)

    redis_host = ('127.0.0.1')
    @@redis = Redis.new(host: redis_host, port: 6379)
  end

end
