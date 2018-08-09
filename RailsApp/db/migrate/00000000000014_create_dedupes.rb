class CreateDedupes < ActiveRecord::Migration
  def change
    create_table :dedupes do |t|
      t.references :count, index: true
      t.references :concrete_field, index: true
      t.integer :position
      t.string :tiebreak
    end
  end
end

