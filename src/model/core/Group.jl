mutable struct Group <: Node
    child_list::Vector{Node}
    child_index_current::Int
    parent::Union{WeakRef, Nothing}
    mode::Symbol
    callback_enter::Vector{<:Function}
    callback_exit::Vector{<:Function}
end

Group(
    child_list::Vector;
    child_index_current::Int           = 1,
    parent::Union{WeakRef, Nothing}    = nothing,
    mode::Symbol                       = :sequential,
    callback_enter::Vector{<:Function} = Function[],
    callback_exit::Vector{<:Function}  = Function[]
) = Group(Vector{Node}(child_list), child_index_current, parent, mode, callback_enter, callback_exit)

function equal(a::Group, b::Group)
    a.child_index_current == b.child_index_current ||
        return false
    typeof(a.parent) == typeof(b.parent) ||
        return false
    a.mode == b.mode ||
        return false
    a.callback_enter == b.callback_enter ||
        return false
    a.callback_exit  == b.callback_exit  ||
        return false
    length(a.child_list) == length(b.child_list) ||
        return false
    for (ca, cb) in zip(a.child_list, b.child_list)
        equal(ca, cb) || return false
    end
    return true
end

AbstractTrees.nodevalue(group::Group) = (
    child_list          = group.child_list,
    child_index_current = group.child_index_current,
    mode                = group.mode,
    callback_enter      = group.callback_enter,
    callback_exit       = group.callback_exit
)

AbstractTrees.children(group::Group) = group.child_list

AbstractTrees.childtype(::Type{Group}) = Node

AbstractTrees.parent(group::Group) = group.parent === nothing ? nothing : group.parent.value

AbstractTrees.ParentLinks(::Type{Group}) = StoredParents()

AbstractTrees.ChildIndexing(::Type{Group}) = AbstractTrees.IndexedChildren()