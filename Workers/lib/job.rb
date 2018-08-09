require 'resque'
require 'resque-status'
require_relative '../config/version'

require_relative 'extensions/core_extensions'
require_relative 'decorated_payload'
require_relative 'configuration'

class Job

  UNKNOWN_JOB_ID = '<unknown>' # default for when cannot read payload
  DATE_FORMAT = 

  include Resque::Plugins::Status
  using CoreExtensions

  def perform
    self.run
  end

  def run
    begin
      log.info ">>> START JOB - QUEUE: #{ENV['QUEUE']}"
      log.info ">>> ID: ##{job_id}"

      tick('working_at' => formatted_current_time)
      inner_run
    rescue StandardError => e
      failed('failed_at' => formatted_current_time)

      error_msg = "JOB: ##{job_id} - #{e.class.name}: #{e.message}\n"
      error_msg << "\t#{e.backtrace.join("\n\t")}"
      log.error error_msg
      raise e
    ensure
      log.info "<<< FINISH JOB: ##{job_id}"
    end
  end

  def inner_run
    raise NoMethodError.new("undefined method `inner_run' for #{self.class}")
  end

  private
    def run_total_count
      options_struct.selects.each do |select|
        log.info "Processing #{select.ui_data_type}"

        payload.field = select
        UploadFileTask.run if select.respond_to?(:files)
        
        Classes::Select.new(
          select, payload.header, payload.simple_count_result_key
        ).run

        result = RedisOperations.bitcount(payload.simple_count_result_key)
        log.info "Partial result: #{result}"
      end

      ['order', 'file'].each do |suppress_type|
        suppress_objects = Classes::Suppress.build(
                              options_struct.send("suppress_#{suppress_type}"),
                              payload.header,
                              suppress_type
                            )

        suppress_objects.each do |suppress|
          suppress.run(payload.simple_count_result_key)
          result = RedisOperations.bitcount(payload.simple_count_result_key)
          log.info "Partial result: #{result}"
        end
      end

      unless options_struct.dedupes.empty?
        dedupe_struct = options_struct.dedupes.first
        log.info "Processing #{dedupe_struct.ui_data_type} dedupe"

        dedupe = Classes::Dedupe.new(
          dedupe_struct, payload.header, payload.simple_count_result_key
        )

        dedupe.run

        log.info "Dedupe result: #{RedisOperations.bitcount(dedupe.deduped_count_result_key)}"
      end
    end

    def options_struct
      @options_struct ||= options.to_struct(deep: true)
    end

    def payload
      @payload ||= DecoratedPayload.instance.tap do |pl|
                     pl.header = options_struct.header
                   end
    end

    def job_id
      return @job_id if defined? @job_id

      # TO-DO: We've seen it failing to retrieve the job_id because of issues 
      # trying to read other elements from the payload. But there most be 
      # a way of flawlessly retrieving the job_id no matter what.
      begin
        @job_id = payload.header.job_id.to_s
      rescue StandardError => e
        @job_id = UNKNOWN_JOB_ID
        raise e
      end
    end

    def formatted_current_time
      Time.at(*Resque.redis.redis.time).strftime("%F %T.%3N %z")
    end

    # Alias
    def log; Configuration.logger; end
end
