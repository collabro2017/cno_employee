class AddEnabledFieldColumnsToConcreteField < ActiveRecord::Migration
  def change
    add_column :concrete_fields, :select_enabled, :boolean, default: false
    add_column :concrete_fields, :breakdown_enabled, :boolean, default: false
    add_column :concrete_fields, :dedupe_enabled, :boolean, default: false
    add_column :concrete_fields, :output_enabled, :boolean, default: false
    add_column :concrete_fields, :sort_enabled, :boolean, default: false
  end
end
