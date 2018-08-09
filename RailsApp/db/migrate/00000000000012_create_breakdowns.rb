class CreateBreakdowns < ActiveRecord::Migration
  def change
    create_table :breakdowns do |t|
      t.references :count, index: true
      t.references :concrete_field, index: true
      t.integer :position

      t.timestamps
    end
  end
end

