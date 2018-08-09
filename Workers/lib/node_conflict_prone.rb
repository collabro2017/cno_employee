module NodeConflictProne

  def local_value_id_conflicts
    # Comes like this: {:"203"=>[1, 2], :"407"=>[2, 3], :"750"=>[4, 5]}
    all_conflicts = options_struct.conflict_values.to_h
    
    my_conflicts = all_conflicts.select do |value_id, nodes|
                     nodes.include?(node_id)
                   end

    # Value ids
    my_conflicts.keys.map(&:to_s).map(&:to_i)
  end

end
