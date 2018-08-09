class CreateCountsAndSuppressionOrders < ActiveRecord::Migration
  def change
    create_table :counts_orders, id: false do |t|
      t.belongs_to :count
      t.belongs_to :order
    end
  end
end

