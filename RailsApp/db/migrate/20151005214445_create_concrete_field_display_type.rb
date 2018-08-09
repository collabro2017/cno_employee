class CreateConcreteFieldDisplayType < ActiveRecord::Migration
  def change
    create_table :concrete_field_display_types do |t|
      t.string :display_type
      t.references :concrete_field, index: true
    end
  end
end
