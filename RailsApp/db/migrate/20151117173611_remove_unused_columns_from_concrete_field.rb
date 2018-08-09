class RemoveUnusedColumnsFromConcreteField < ActiveRecord::Migration
  def change
    remove_column :concrete_fields, :selectable, :boolean
    remove_column :concrete_fields, :breakdown, :boolean, default: true
    remove_column :concrete_fields, :output, :boolean
    remove_column :concrete_fields, :enabled, :boolean
  end
end
