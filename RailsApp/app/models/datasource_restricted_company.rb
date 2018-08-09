class DatasourceRestrictedCompany < ActiveRecord::Base
  belongs_to :datasource
  belongs_to :company

  validates_presence_of :datasource
  validates_presence_of :company
end