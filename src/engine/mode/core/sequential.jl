function sequential(group::Model.Group)::Vector{Int}
    index = group.child_index_current
    if index <= length(group.child_list)
        group.child_index_current += 1
        return [group.child_index_current - 1]
    else
        return Int[]
    end
end

set!(:sequential, sequential)