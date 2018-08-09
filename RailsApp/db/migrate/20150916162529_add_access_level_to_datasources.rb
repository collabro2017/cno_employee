class AddAccessLevelToDatasources < ActiveRecord::Migration
  def change
    add_column :datasources, :access_level, :string
  end
end
