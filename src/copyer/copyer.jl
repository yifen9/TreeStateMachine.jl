module Copyer

export copy

using ..Model

function copy(leaf::Model.Leaf)::Model.Leaf
    value_new = deepcopy(leaf.value)
    return Model.Leaf(
        value_new;
        parent        = leaf.parent,
        callback_list = Base.copy(leaf.callback_list)
    )
end

function copy(group::Model.Group)::Model.Group
    group_new = Model.Group(
        Vector{Model.Node}();
        child_index_current = group.child_index_current,
        parent              = group.parent,
        mode                = group.mode,
        callback_list       = Base.copy(group.callback_list)
    )
    for child in group.child_list
        child_new = copy(child)
        push!(group_new.child_list, child_new)
    end
    return group_new
end

end