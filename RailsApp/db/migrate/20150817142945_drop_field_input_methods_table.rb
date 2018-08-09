class DropFieldInputMethodsTable < ActiveRecord::Migration
  def up
    remove_index :field_input_methods, name: :index_field_input_methods_on_field_id
    drop_table :field_input_methods
  end

  def down
    create_table :field_input_methods do |t|
      t.references :field, index: true
      t.integer :position
      t.string :input_method_type

      t.timestamps
    end
  end
end
