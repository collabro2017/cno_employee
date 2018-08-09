class CreateUserFiles < ActiveRecord::Migration
  def change
    create_table :user_files do |t|
      t.references :user, index: true
      t.string :name
      t.datetime :uploaded_at
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end

