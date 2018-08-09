class DropLookupOptionsTable < ActiveRecord::Migration
  def up
    remove_index :lookup_options, name: :index_lookup_options_on_concrete_field_id
    drop_table :lookup_options
  end

  def down
    create_table :lookup_options do |t|
      t.references :concrete_field, index: true
      t.string :lookup_class_name

      t.timestamps
    end
  end
end
