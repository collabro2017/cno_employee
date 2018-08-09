class CreateSelects < ActiveRecord::Migration
  def change
    create_table :selects do |t|
      t.references :count, index: true
      t.references :concrete_field, index: true
      t.integer :position
      t.integer :from
      t.integer :to
      t.string :blanks
      t.boolean :has_values
      t.boolean :has_ranges
      t.boolean :has_blanks_criterion
      t.boolean :has_files, default: false
      t.boolean :exclude, default: false
      t.boolean :linked_to_next

      t.timestamps
    end
  end
end

