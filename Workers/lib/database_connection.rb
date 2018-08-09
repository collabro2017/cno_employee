require 'pg'
require 'sequel'
require_relative 'configuration'

class DatabaseConnection

  @@pool = Hash.new

  def self.[](database)
    return @@pool[database] if !!@@pool[database]
    @@pool[database] = Sequel.connect(Configuration.db_config[database])
    @@pool[database].extension :pg_array
  end

end
