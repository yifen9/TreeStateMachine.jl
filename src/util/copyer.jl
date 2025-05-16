module Copyer

export copy

using ..Model

function copy(leaf::Model.Leaf)
    value_new = deepcopy(leaf.value)
    return Model.Leaf(
        value_new;
        parent         = nothing,
        callback_enter = Base.copy(leaf.callback_enter),
        callback_exit  = Base.copy(leaf.callback_exit)
    )
end

function copy(group::Model.Group)
    group_new = Model.Group(
        Vector{Model.Node}();
        child_index_current = group.child_index_current,
        parent              = nothing,
        mode                = group.mode,
        callback_enter      = Base.copy(group.callback_enter),
        callback_exit       = Base.copy(group.callback_exit)
    )
    for child in group.child_list
        child_new = copy(child)
        push!(group_new.child_list, child_new)
    end
    return group_new
end

end