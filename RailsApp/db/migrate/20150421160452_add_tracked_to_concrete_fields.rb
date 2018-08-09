class AddTrackedToConcreteFields < ActiveRecord::Migration
  def change
    add_column :concrete_fields, :tracked, :boolean
  end
end
