class CreateOrderStatistics < ActiveRecord::Migration
  def change
    create_table :order_statistics do |t|
      t.references :job, index: true
      t.references :concrete_field, index: true
      t.integer :populated_count
      t.timestamps
    end
  end
end
