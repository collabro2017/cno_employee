class CreateSorts < ActiveRecord::Migration
  def change
    create_table :sorts do |t|
      t.references :order, index: true
      t.references :concrete_field, index: true
      t.integer :position
      t.boolean :descending, default: false

      t.timestamps
    end
  end
end

