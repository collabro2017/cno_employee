class AddNumericSortToConcreteFields < ActiveRecord::Migration
  def change
    add_column :concrete_fields, :numeric_sort, :boolean
  end
end
