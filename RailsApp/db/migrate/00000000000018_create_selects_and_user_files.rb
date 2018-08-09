class CreateSelectsAndUserFiles < ActiveRecord::Migration
  def change
    create_table :selects_user_files, id: false do |t|
      t.belongs_to :user_file
      t.belongs_to :select
    end
  end
end

