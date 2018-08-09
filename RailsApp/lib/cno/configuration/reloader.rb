module CNO
  module Configuration
    class Reloader

      def self.def(name, &block)
        self.define_singleton_method(name) do
          table_name = 'custom_configurations'
          yield(block) if ActiveRecord::Base.connection.table_exists? table_name
        end
        self.send(name)
      end

    end
  end
end
