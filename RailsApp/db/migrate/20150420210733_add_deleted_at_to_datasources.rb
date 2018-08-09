class AddDeletedAtToDatasources < ActiveRecord::Migration
  def change
    add_column :datasources, :deleted_at, :timestamp
  end
end
