module MemoryStatus
  extend ActiveSupport::Concern

  included do
    before_create { self.created_at = redis_time }
  end

  def sync_status
    cached = resque_status

    JobStatus.each do |status|
      timestamp = "#{status.to_s}_at"
      if self.public_send(timestamp).nil? && cached[timestamp]
        self.public_send("#{timestamp}=", Time.parse(cached[timestamp]))
      end
    end

    self.status = cached.status.to_sym
    save_result_values if self.status == :completed
    save
  end

  private
    def resque_status
      self.class.resque_status(id)
    end

    def redis_time
      Time.at(*Resque.redis.redis.time)
    end

  module ClassMethods
    def status(id)
      if(cached = resque_status(id))
        unless cached['last_status'] && cached.status == cached['last_status']
          update_last_status_in_resque(id)

          # Materialize (access DB) only if inside this condition
          self.find(id).sync_status
        end
        cached.status
      else
        # Materialize only if inside this condition too
        :failed if self.find(id).mark_as(:failed)
      end
    end

    def update_last_status_in_resque(id)
      cached = resque_status(id)
      cached['last_status'] = cached.status
      Resque::Plugins::Status::Hash.set(id, cached)
    end

    def resque_status(id)
      Resque::Plugins::Status::Hash.get(id)
    end
  end

end
