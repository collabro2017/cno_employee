module DatafilesDatabase
  class Base < ActiveRecord::Base
    @abstract_class = true
    establish_connection(:"central_datastore_#{Rails.env}")
    self.table_name_prefix = 'datafiles.'
  end
end
