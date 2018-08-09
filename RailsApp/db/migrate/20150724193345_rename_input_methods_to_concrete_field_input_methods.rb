class RenameInputMethodsToConcreteFieldInputMethods < ActiveRecord::Migration
  def change
    rename_table :input_methods, :concrete_field_input_methods
  end 
end
