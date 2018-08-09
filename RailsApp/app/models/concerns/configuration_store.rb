module ConfigurationStore
  module ActsAsConfigurationStore
    extend ActiveSupport::Concern

    module ClassMethods
      def acting_as_configuration_store?
        false # is false until acts_as_configuration_store is called
      end

      def acts_as_configuration_store(options = {})
        column_name_methods = ''
        key_column = (options[:key_column] || :parameter).to_s
        value_column = (options[:value_column] || :value).to_s

        if self.connection.table_exists?(self.table_name)
          if (unknown = ([key_column, value_column] - self.column_names)).empty?
            column_name_methods = %(
              def self.key_column
                :#{key_column}
              end

              def self.value_column
                :#{value_column}
              end
            )
          else
            unknown.map! { |s| "'#{s}'" }
            plural = unknown.size > 1 ? 's' : ''
            raise ArgumentError,
              "Column#{plural} #{unknown.to_sentence} not found in #{self}"
          end
        else
          raise StandardError, "Table #{self.table_name} does not exist"
        end

        class_eval %(
          validates :#{key_column}, presence: true, uniqueness: true

          before_validation :convert_key_to_symbol
          before_save       :handle_boolean_values
          after_commit      :refresh_cached_value, on: [:create, :update]

          #{column_name_methods}

          def self.namespaced_cache_key(key)
            "\#\{self.table_name\}:\#\{key\}"
          end

          def self.acting_as_configuration_store?
            true
          end

          def self.to_h
            self.all.each.with_object({}) do |record, hash|
              hash[record[self.key_column].to_sym] = record[self.value_column]
            end
          end

          include LocalInstanceMethods
        )
      end
    end
 
    module LocalInstanceMethods
      private
        def convert_key_to_symbol
          self[self.class.key_column] = key.underscore
        end

        def handle_boolean_values
          value_column = self.class.value_column
          if self.public_send("#{value_column}_changed?") && value_is_boolean?
            new_value = self[value_column]
            self[value_column] = nil
            self.save
            self.class.where(id: self.id).update_all(
              value_column => new_value.to_json
            )
            self.reload
          end
        end

        def value_is_boolean?
          current_value = self[self.class.value_column]
          !!current_value == current_value # trick to test if is boolean
        end

        def refresh_cached_value
          Rails.cache.write(self.class.namespaced_cache_key(key), self)
        end

        def key
          self[self.class.key_column]
        end

    end

  end
end

ActiveRecord::Base.send :include, ConfigurationStore::ActsAsConfigurationStore

