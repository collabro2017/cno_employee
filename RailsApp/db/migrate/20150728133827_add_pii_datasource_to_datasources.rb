class AddPiiDatasourceToDatasources < ActiveRecord::Migration
  def change
    add_reference :datasources, :pii_datasource, references: :datasources
  end
end
