class AddEnabledToConcreteFieldInputMethods < ActiveRecord::Migration
  def change
    add_column :concrete_field_input_methods, :enabled, :boolean, default: true
  end
end
