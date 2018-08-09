class CreateLookupOptions < ActiveRecord::Migration
  def change
    create_table :lookup_options do |t|
      t.references :concrete_field, index: true
      t.string :lookup_class_name

      t.timestamps
    end
  end
end

