class Company < ActiveRecord::Base
  has_many :users

  has_many :datasource_restricted_companies
  has_many :datasources, through: :datasource_restricted_companies

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true

  def self.restricted_by_datasource(datasource_id:)
    selected = 
      DatasourceRestrictedCompany.where(datasource_id: datasource_id).all
    
    Company.where.not(id: selected.pluck(:company_id))
  end

end
