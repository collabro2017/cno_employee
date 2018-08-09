require 'erb'
require_relative '../extensions/core_extensions'

module SqlCode
  class Renderer < ERB

    using CoreExtensions

    attr_reader :values, :template_name

    def initialize(template_name:, values:)
      @template_name = template_name
      @values = values
      super(template)
    end

    def result
      expose_values
      super(binding)
    rescue SyntaxError => e
      error_msg = "#{e.class.name}: #{e.message}\n"
      error_msg << "\t#{e.backtrace.join("\n\t")}"
      log.error error_msg
      # TO-DO: create a special type of error for SyntaxError in templates that
      # inherits at some level from StandardError
      raise "SyntaxError found in #{template_name}"
    end

    def render_partial(template_name, values)
      self.class.new(template_name: "_#{template_name}", values: values).result
    end

    private
      def expose_values
        values.each do |key, value|
          define_singleton_method(key) do 
            value.is_a?(Hash) ? value.to_struct(deep: true) : value
          end
        end
      end

      def template
        return @template if defined?(@template)
        templates_dir = File.join(File.dirname(__FILE__), 'sql_templates')
        filename = File.join(templates_dir, "#{template_name}.sql.erb")
        @template = File.read(filename)
      end

      #Alias
      def log; Configuration.logger; end

  end
end
