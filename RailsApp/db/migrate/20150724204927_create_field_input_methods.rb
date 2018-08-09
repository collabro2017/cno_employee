class CreateFieldInputMethods < ActiveRecord::Migration
  def change
    create_table :field_input_methods do |t|
      t.references :field, index: true
      t.integer :position
      t.string :input_method_type

      t.timestamps
    end
  end
end
