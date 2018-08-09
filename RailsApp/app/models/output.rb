class Output < ActiveRecord::Base
  belongs_to :order
  belongs_to :concrete_field

  validates_presence_of :order

  include Sortable
  self.scope_attribute = :order

  def escaped_caption
    concrete_field.present? ? "\"#{self.concrete_field.caption}\"" : ""
  end

  def caption
    concrete_field.present? ? concrete_field.caption : 'No concrete_field'
  end

  def name
    concrete_field.present? ? concrete_field.name : 'No concrete_field'
  end

end

