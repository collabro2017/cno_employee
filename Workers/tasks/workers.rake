require 'yaml'
require 'resque/tasks'
require 'erb'
require_relative '../config/version'

Dir[Dir.pwd + '/lib/**/*.rb'].each { |file| require file }

#------------------------------------------------------------------------------#

@environment     = ENV['ENV'] || 'development'
@config_filename = "#{File.dirname(__FILE__)}/../config/resque.yml"

ENV['QUEUE'] += "_#{Worker::VERSION}"
ENV['YELL_ENV']  = @environment
log = Configuration.logger

namespace :workers do

  desc 'Initialize Resque'
  task :run do

    log.info "*********** Starting Worker ***************"
    log.info "App Name:        #{ENV['APP_NAME'].inspect}"
    log.info "Environment:     #{@environment.inspect}"
    log.info "Node ID:         #{ENV['NODE_ID'].inspect}"
    log.info "Listening Queue: #{ENV['QUEUE'].inspect}"
    log.info "Code version:    #{Worker::VERSION.inspect}"
    log.info "*******************************************"

    begin
      config_file = ERB.new(File.read(@config_filename)).result
      config = YAML.load(config_file)[@environment]
      Resque.redis = config['redis_host']

      log.info "Redis configuration:"
      config.each { |key, value| log.info "  #{key}: #{value.inspect}" }
      
      if ENV['APP_NAME']
        Rake::Task['resque:work'].invoke
      else
        $stderr.puts "You need to specify APP_NAME"
        raise
      end
    rescue StandardError => e
      Rake::Task['resque:work'].reenable
      log.error e.clean_message(Dir.pwd)

      retry_delay = config['connection_retry_delay']
      retry_msg = "Error trying to run resque:work rake task. "
      retry_msg << "Retrying in #{retry_delay} seconds"
      $stderr.puts retry_msg
      sleep retry_delay
      retry
    end
  end
end
