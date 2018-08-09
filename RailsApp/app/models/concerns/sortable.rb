module Sortable

  extend ActiveSupport::Concern
  
  included do
    before_save :update_positions_before_save
    after_destroy :update_positions_after_destroying
    class_attribute :scope_attribute
  end

  def scope_value
    self.send(scope_attribute)
  end
    
  def scope_value=(value)
    self.send("#{scope_attribute}=", value)
  end

  def next
    scoped.find_by(position: self.position + 1)
  end

  def previous
    scoped.find_by(position: self.position - 1)
  end

  private    
    def update_positions_before_save
      next_max = next_max_position

      if (self.position.nil? ||
          self.position > next_max ||
          self.position < 0
      )
        if scope_attribute.nil? || !!scope_value
          self.position = next_max
        end
      elsif self.position_changed? && self.position < next_max   
        if self.position_was
          update_positions_of_higher_or_equal_than(self.position_was, '-')
        end
        update_positions_of_higher_or_equal_than(self.position, '+')
      end
    end

    def update_positions_after_destroying
      unless self.position.nil?
        update_positions_of_higher_or_equal_than(self.position, '-')
      end
    end 
    
    #---
    
    def update_positions_of_higher_or_equal_than(position, action)
      group = scoped.where("position >= ?", position)
      group.update_all("position = position %s 1" % action)
    end

    def next_max_position
      scoped.count
    end

    def scoped
      scope_attribute = self.class.scope_attribute      
      if scope_attribute
        scoped = self.class.where(scope_attribute => scope_value)
      else
        scoped = self.class
      end
    end
    
  module ClassMethods
    
    def default_scope
      order(:position)
    end 
    
  end
  
end
