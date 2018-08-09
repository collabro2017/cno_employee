module CNO
  module Configuration
    class Accessor < CNO::Common::BlankSlate
  
      def initialize(model_class_name=nil, options={})
        super() # empty parenthesis are required in this scenario
        if model_class_name
          @table_name = options[:table_name] || model_class_name.tableize
          @model_class_name = model_class_name
        end
      end

      def method_missing(method, *args, &block)
        method_name = method.to_s
        if /^(?<parameter>\w+)=$/ =~ method_name
          set_value(parameter, args.first)
        elsif !(value = get_value(method_name)).nil? # false is a valid value
          value
        else
          nil_if_no_method_error(method_name) { super }
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        true
      end

      def inspect
        "#<CNO::Configuration::Accessor #{model_inspect} #{default_inspect}>"
      end

      private

        def get_value(param)
          default_value = CNO::RailsApp.config.default[param]

          if model
            get_record(param, default_value).public_send(model.value_column)
          elsif default_value.is_a?(Hash)
            RecursiveOpenStruct.new(default_value, recurse_over_array: true)
          else
            default_value
          end
        end

        def get_record(param, default_value)
          Rails.cache.fetch(model.namespaced_cache_key(param)) do
            record = model.find_or_initialize_by(model.key_column => param)

            record_value = record[model.value_column]

            if record_value.nil?
              record[model.value_column] = default_value
            elsif record_value.is_a?(Hash) && default_value.is_a?(Hash)
              record[model.value_column] = default_value.merge(record_value)
            end
            record
          end
        end

        def set_value(param, value)
          if model
            record = model.find_or_initialize_by(model.key_column => param)
            record.public_send("#{model.value_column}=", value)
            record.save
          else
            raise ActiveRecordError::ReadOnlyRecord, 'Trying to set a value' + \
              ' configuration option but the model does not exist yet.'
          end
        end

        def nil_if_no_method_error(method_name, &block)
          ret = nil

          begin
            ret = yield if block_given?
          rescue NoMethodError => e
            if e.message.include?("undefined method `#{method_name}'")
              ret = nil
            else
              raise e
            end
          end

          ret
        end

        def model
          conn = ActiveRecord::Base.connection
          if @model_class_name && conn.table_exists?(@table_name)
            @model ||= @model_class_name.constantize
          end
        end

        def model_inspect
          "#{model} parameters: #{model.to_h}" if model
        end

        def default_inspect
          "Default parameters: #{CNO::RailsApp.config.default}"
        end

    end #Accessor
  end #Configuration
end #CNO
