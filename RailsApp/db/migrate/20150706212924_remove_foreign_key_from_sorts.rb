class RemoveForeignKeyFromSorts < ActiveRecord::Migration
  def up
    remove_foreign_key :sorts, name: :fk_sorts_concrete_field_id
  end

  def down
    add_foreign_key :sorts, ["concrete_field_id"], "concrete_fields", ["id"], name: :fk_sorts_concrete_field_id
  end
end
