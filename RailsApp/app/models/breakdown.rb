class Breakdown < ActiveRecord::Base

  belongs_to :count
  belongs_to :concrete_field

  validates_presence_of :count
  validates_presence_of :concrete_field
  
  delegate :caption,
           :name,
           :db_data_type,
           :ui_data_type,
           :default_lookup_class,
           to: :concrete_field
  
  include Sortable
  self.scope_attribute = :count

end

