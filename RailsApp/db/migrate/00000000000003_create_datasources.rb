class CreateDatasources < ActiveRecord::Migration
  def change
    create_table :datasources do |t|
      t.string :name
      t.string :type
      t.string :caption
      t.string :image_location
      t.integer :total_records
      t.text :description

      t.timestamps
    end
  end
end

