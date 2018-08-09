class CreateOutputs < ActiveRecord::Migration
  def change
    create_table :outputs do |t|
      t.references :order, index: true
      t.references :concrete_field, index: true
      t.integer :position

      t.timestamps
    end
  end
end

