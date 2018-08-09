module JSONWrapper
  module HasJSONColumns
    extend ActiveSupport::Concern

    module ClassMethods
      def wrap_json_columns(*json_column_names)
        json_column_names.each do |column_name|
          class_eval %(
            before_save :convert_#{column_name}_to_json
            after_save :convert_#{column_name}_back_from_json

            def #{column_name}
              val = self[:#{column_name}]
              if val.is_a?(Hash)
                JSONWrapper::JSONDatatypeWrapper.new(
                  val,
                  record: self,
                  column_name: :#{column_name},
                  force_save: true
                )
              else
                val
              end
            end

            def convert_#{column_name}_to_json
              @old_#{column_name} = nil
              if #{column_name}.is_a?(String)
                @old_#{column_name} = #{column_name}.dup
                self[:#{column_name}] = #{column_name}.to_json
              end
            end

            def convert_#{column_name}_back_from_json
              unless @old_#{column_name}.nil?
                self[:#{column_name}] = @old_#{column_name}
              end
            end
          )
        end
      end # wrap_json_columns
    end # ClassMethods
 
  end
end

ActiveRecord::Base.send :include, JSONWrapper::HasJSONColumns

