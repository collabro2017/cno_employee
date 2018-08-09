module ProcessDatabase
  class Base < ActiveRecord::Base
    @abstract_class = true
    establish_connection(:"central_datastore_#{Rails.env}")
    self.table_name_prefix = 'process.'
    
    def self.drop_all_tables
      self.connection.tables.each do |table_name|
        self.connection.drop_table(table_name)
      end
    end
    
    def self.truncate_all_tables
      self.connection.tables.each do |table_name|
        self.connection.execute "TRUNCATE TABLE #{table_name};"
      end
    end
  end
end
