class CreateConcreteFields < ActiveRecord::Migration
  def change
    create_table :concrete_fields do |t|
      t.references :field_category, index: true
      t.references :datasource, index: true
      t.references :field, index: true
      t.string :name
      t.string :caption
      t.string :db_data_type
      t.string :ui_data_type
      t.string :printf_format
      t.string :pg_format
      t.string :source_fields, array: true
      t.integer :position
      t.integer :default_output_layout
      t.integer :min, limit: 8
      t.integer :max, limit: 8
      t.integer :distinct_count
      t.boolean :selectable
      t.boolean :open, default: false
      t.boolean :breakdown, default: true
      t.boolean :favorite
      t.boolean :enabled
      t.boolean :lookup_enabled, default: true
      t.boolean :output
      t.boolean :record_key
      t.json :conflict_values

      t.timestamps
    end
  end
end

