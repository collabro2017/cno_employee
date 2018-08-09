class CreateInputMethods < ActiveRecord::Migration
  def change
    create_table :input_methods do |t|
      t.references :concrete_field, index: true
      t.integer :position
      t.string :input_method_type

      t.timestamps
    end
  end
end
