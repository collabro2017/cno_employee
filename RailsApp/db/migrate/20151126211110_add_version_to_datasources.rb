class AddVersionToDatasources < ActiveRecord::Migration
  def change
    add_column :datasources, :version, :string
  end
end
