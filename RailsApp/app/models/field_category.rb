class FieldCategory < ActiveRecord::Base
  has_many :concrete_fields
  validates_uniqueness_of :name
  
  def self.default
    self.find_or_create_by(name: "Uncategorized")
  end

  def sorted_concrete_fields_from_datasource(datasource, display_type)
    key = :"#{display_type}_enabled"

    self.concrete_fields
    .where(key => true)
    .eager_load_fields
    .where(datasource: datasource)
    .to_a
    .sort_by(&:caption)
  end
end
