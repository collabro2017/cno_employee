module Enumerable

  if instance_methods.map(&:to_s).include?('loop_with_enumerator')
    fail '#loop_with_enumerator already defined on Enumerable'
  end

  # Public: Iterates passing the Enumerator object to the block. Useful when
  # the Enumerator cursor needs to be directly manipulated inside the loop.
  #
  # Examples
  #
  #   a = [1, 2, 3, 4, 5]
  #
  #   a.loop_with_enumerator do |n, e|
  #     if n != 3
  #       puts n
  #     else
  #       # Loop through the rest doing something else.
  #       e.loop_with_enumerator { |i, e| puts "After 3: #{i}" }
  #     end
  #   end
  #
  #   # => 1
  #   # => 2
  #   # => After 3: 3
  #   # => After 3: 4
  #   # => After 3: 5
  #
  # Returns the enumerator. If a block is given, passes the peek object and the 
  # enumerator with its current position to the block; moves the cursor after 
  # the block.
  def loop_with_enumerator(&block)
    enumerator = self.each
    if block_given?
      loop do
        begin
          yield(enumerator.peek, enumerator)
          enumerator.next
        rescue StopIteration
          break 
        end
      end
    end
    enumerator
  end

  if instance_methods.map(&:to_s).include?('enumerator_stopped_at')
    fail '#enumerator_stopped_at already defined on Enumerable'
  end

  # Public: Iterates through an enumerator until the condition in the block is
  # met.
  #
  # Examples
  #
  #   a = [1, 2, 3, 4, 5]
  #
  #   enum = a.enumerator_stopped_at { |n| n % 3 == 0 }
  #   enum.next # => 3
  #
  # Returns the enumerator. If a block is given, passes the next element 
  # to the block; the iteration stops when evaluating the block yields true.
  def enumerator_stopped_at(&block)
    enumerator = self.each
    if block_given?
      loop do
        begin
          break if yield(enumerator.peek)
          enumerator.next
        rescue StopIteration
          break 
        end
      end
    end
    enumerator
  end

end

