class CreateDatasourceRestrictedCompanies < ActiveRecord::Migration
  def change
    create_table :datasource_restricted_companies do |t|
      t.references :datasource, index: true
      t.references :company, index: true
    end
  end
end
