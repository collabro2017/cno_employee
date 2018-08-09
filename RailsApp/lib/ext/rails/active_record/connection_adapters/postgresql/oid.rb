require 'active_record/connection_adapters/postgresql_adapter'

# Fixes being able to assign a string to a JSON column
module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      module OID # :nodoc:
        class Json < Type # :nodoc:
          def type_cast(value)
            begin
              ConnectionAdapters::PostgreSQLColumn.string_to_json value
            rescue JSON::ParserError
              value.to_json
            end
          end
        end
      end
    end
  end
end

