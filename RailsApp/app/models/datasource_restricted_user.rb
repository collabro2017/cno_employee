class DatasourceRestrictedUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :datasource
end