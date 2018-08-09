class RemoveOpenFromConcreteFields < ActiveRecord::Migration
  def change
    remove_column :concrete_fields, :open, :boolean, default: false
  end
end
