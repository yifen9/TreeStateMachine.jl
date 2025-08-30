function parallel(group::Model.Group)::Vector{Int}
    return findall(child -> child.status !== :done, group.child_list)
end

set!(:parallel, parallel)