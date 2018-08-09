class DropConcreteFieldDisplayTypesTable < ActiveRecord::Migration
  def up
    remove_index :concrete_field_display_types,
      name: :index_concrete_field_display_types_on_concrete_field_id
    drop_table :concrete_field_display_types
  end

  def down
    create_table :concrete_field_display_types do |t|
      t.string :display_type
      t.references :concrete_field, index: true
    end
  end
end
