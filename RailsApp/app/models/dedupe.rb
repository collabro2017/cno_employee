class Dedupe < ActiveRecord::Base
  after_initialize :default_values

  belongs_to :count
  belongs_to :concrete_field

  validates_presence_of :count
  validates_presence_of :concrete_field
  
  delegate :caption, to: :concrete_field
  
  include Sortable
  self.scope_attribute = :count

  private
    def default_values
      self.tiebreak ||= "MAX"
    end

end
