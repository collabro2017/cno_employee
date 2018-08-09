class Enumerator

  if instance_methods.map(&:to_s).include?('continue_each')
    fail '#continue_each already defined on Enumerable'
  end

  # Just like #each but continues where the current position is at. 
  #
  # Examples
  #
  #   e = [1, 2, 3, 4, 5].each
  #
  #   e.next
  #
  #   e.continue_each { |n| puts n }
  #
  #   # => 2
  #   # => 3
  #   # => 4
  #   # => 5
  #
  # Returns the enumerator. If a block is given, passes each object to the 
  # the block.
  def continue_each(&block)
    if block_given?
      loop do
        begin
          yield(self.peek)
          self.next
        rescue StopIteration
          break 
        end
      end
    end
    self    
  end

end

