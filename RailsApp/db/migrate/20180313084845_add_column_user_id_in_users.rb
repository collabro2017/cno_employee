class AddColumnUserIdInUsers < ActiveRecord::Migration
  def change
    add_column :users, :userid, :string, unique: true
  end
end
