class RemoveLookupEnabledFromConcreteFields < ActiveRecord::Migration
  def change
    remove_column :concrete_fields, :lookup_enabled, :boolean, default: false
  end
end
