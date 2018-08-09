class RemoveForeignKeyFromOutputs < ActiveRecord::Migration
  def up
    remove_foreign_key :outputs, name: :fk_outputs_concrete_field_id
  end

  def down
    add_foreign_key :outputs, ["concrete_field_id"], "concrete_fields", ["id"], name: :fk_outputs_concrete_field_id
  end
end
