class CreateCounts < ActiveRecord::Migration
  def change
    create_table :counts do |t|
      t.string :name
      t.integer :user_id
      t.integer :datasource_id
      t.integer :parent_id
      t.integer :result
      t.boolean :locked
      t.boolean :dirty

      t.timestamps
    end
  end
end

