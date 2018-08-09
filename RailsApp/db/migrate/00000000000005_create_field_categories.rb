class CreateFieldCategories < ActiveRecord::Migration
  def change
    create_table :field_categories do |t|
      t.string :name

      t.timestamps
    end
  end
end

