class CreateCustomConfigurations < ActiveRecord::Migration
  def change
    create_table :custom_configurations do |t|
      t.string :parameter
      t.json :value

      t.timestamps
    end
  end
end
