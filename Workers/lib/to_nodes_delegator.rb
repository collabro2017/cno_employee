require 'resque-status'

require_relative 'extensions/core_extensions'
require_relative 'configuration'
require_relative '../config/version'

class ToNodesDelegator

  using CoreExtensions

  attr_reader :payload


  # Enqueues jobs for every node and waits for all of them to finish.
  #
  # ==== Attributes
  #  
  # * +class_name+ - The name of the class that will process the job
  # * +options+ - Hash with options that will be sent to the job
  # * +preparation+ - Block with code that needs to be run for each node before 
  #   enqueuing the jobs. A Struct containing node information is passed to the 
  #   block. The attributes of the node Struct are +id+ and +host+
  # 
  # ==== Examples
  #
  #   # Calling it without the preparation block
  #   delegator = ToNodesDelegator.new
  #   delegator.enqueue('AreaCalculator', {h: 3, w: 20})
  # 
  #   # Calling it with a preparation block that checks if the node is reachable
  #   require 'net/ping' # Net gem
  #   include NET
  #   
  #   delegator = ToNodesDelegator.new
  #   delegator.enqueue('AreaCalculator', {h: 3, w: 20}) do |node|
  #     fail "#{node.host} is unreachable" unless Net::Ping::TCP.new(host).ping?  
  #   end
  def enqueue(klass:, options:, &preparation)
    nodes.each do |node|
      yield(node) if block_given?

      sub_job = Resque::JobWithStatus.enqueue_to(node.host, klass, options)
      sub_jobs << sub_job

      if sub_job.nil?
        raise "failed to enqueue to #{node.host}"
      else
        pending_jobs[sub_job] = node.host
      end
    end
    wait_for_pending_jobs
  end

  def sub_jobs
    @sub_jobs ||= []
  end

  private
    # Returns a list of nodes.
    # Each node is returned as a Struct with the following attributes:
    # * +id+ 
    # * +host+
    def nodes # :nodoc:
      return @nodes if defined?(@nodes) 
      node_ids = (1..Configuration.numbers['total_nodes'])
      @nodes = node_ids.map do |id| 
                {
                  id:   id,
                  host: "node_#{id}_#{Worker::VERSION}"
                }.to_struct
               end
    end

    def pending_jobs
      @pending_jobs ||= {}
    end


    def wait_for_pending_jobs
      while pending_jobs.any?
        pending_jobs.each do |key, host|
          status = Resque::Plugins::Status::Hash.get(key)
          case status.status
          when 'completed'
            pending_jobs.delete(key)
          when 'failed'
            kill_all_pending_jobs
            raise "sub job running on #{host} failed with message: "\
              + "\"#{status['message']}\"\n"
          end
        end

        sleep Configuration.numbers['status_poll_frequency']
      end
    end

    def kill_all_pending_jobs
      pending_jobs.each_key do |key|
        Resque::Plugins::Status::Hash.kill(key)
      end
    end

end
