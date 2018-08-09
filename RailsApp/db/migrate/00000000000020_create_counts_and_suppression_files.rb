class CreateCountsAndSuppressionFiles < ActiveRecord::Migration
  def change
    create_table :counts_user_files do |t|
      t.belongs_to :count
      t.belongs_to :user_file
      t.references :concrete_field, index: true
    end
  end
end

