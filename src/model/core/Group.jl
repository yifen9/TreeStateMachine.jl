mutable struct Group <: Node
    child_list::Vector{Node}
    child_index_current::Int
    parent::Union{WeakRef, Nothing}
    mode::Symbol
    callback_enter::Vector{Function}
    callback_exit::Vector{Function}
end

Group(
    child_list::Vector{<:Node};
    child_index_current::Int           = 1,
    parent::Union{WeakRef, Nothing}    = nothing,
    mode::Symbol                       = :sequential,
    callback_enter::Vector{<:Function} = Function[],
    callback_exit::Vector{<:Function}  = Function[]
)::Group = Group(
    Vector{Node}(child_list),
    child_index_current,
    parent,
    mode,
    Vector{Function}(callback_enter),
    Vector{Function}(callback_exit)
)

function equal(group_a::Group, group_b::Group)::Bool
    group_a.child_index_current === group_b.child_index_current ||
        return false
    typeof(group_a.parent)      === typeof(group_b.parent) ||
        return false
    group_a.mode                === group_b.mode ||
        return false
    group_a.callback_enter      ==  group_b.callback_enter ||
        return false
    group_a.callback_exit       ==  group_b.callback_exit  ||
        return false
    length(group_a.child_list)  === length(group_b.child_list) ||
        return false
    group_zip = zip(group_a.child_list, group_b.child_list)
    for (group_a_child, group_b_child) in group_zip
        equal(group_a_child, group_b_child) || return false
    end
    return true
end

function equal(group_a::Vector{<:Group}, group_b::Vector{<:Group})::Bool
    if length(group_a) === length(group_b)
        group_zip = zip(group_a, group_b)
        for (group_a_item, group_b_item) in group_zip
            !equal(group_a_item, group_b_item) && return false
        end
        return true
    else
        return false
    end
end