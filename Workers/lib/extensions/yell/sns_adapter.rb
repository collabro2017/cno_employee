require 'yell'
require 'active_support/core_ext/string/strip'
require_relative '../../aws_connection'

class SnsAdapter < Yell::Adapters::Base
  include Yell::Helpers::Base

  # Setup is called in your adapters initializer. You are not required to
  # define this method if you have no need for special settings.
  setup { |options| @topic_name = options[:topic_name] }

  # Defining write is mandatory. It's the main adapter method and receives
  # the log event.
  write do |event|
    begin
      @sns = AwsConnection.sns
      @message = event.messages.first
      unless topic.nil?
        topic.publish(format_msg(event), subject: 'Worker Alert')
      end
    rescue StandardError => e
      $stderr.puts e.clean_message(Dir.pwd)
    end
  end

  # Close is reserved for closing a file handle or database connection -
  # it takes no arguments. You are not required to define this method if
  # you have no need for it. 
  close do
    # ... nothing to close ...
  end

  private
    def format_msg(event)
      message = <<-END_CONTENT.strip_heredoc
        Time: #{event.time}
        Level: #{Yell::Severities[event.level]}
        Message: #{@message.each_line.peek}
        Origin:
          Host: #{ENV['HOSTNAME']}
          Worker: #{ENV['QUEUE']}
          File: #{file}
          Line: #{line}
          Method: #{method}
        
        Backtrace:
      END_CONTENT
      
      @message.each_line.with_index do |line, i|
        message << "#{line}" if i > 0
      end

      message
    end

    def file
      @file || (parse_message; @file)
    end

    def line
      @line || (parse_message; @line)
    end

    def method
      @method || (parse_message; @method)
    end

    def parse_message
      regexp = /^\s*(.+?):(\d+)(?::in `(.+)')/

      if m = regexp.match(@message)
        @file, @line, @method = m[1..-1]
      else
        @file, @line, @method = ['', '', '']
      end
    end

    def topic
      @topic ||= @sns.topics.select{ |t| t.name == @topic_name }.first
    end

end

# Register the newly written adapter with Yell
Yell::Adapters.register :sns_adapter, SnsAdapter
