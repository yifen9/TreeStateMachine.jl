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
    parent::Union{WeakRef, Nothing}    = nothing,
    child_index_current::Int           = 1,
    mode::Symbol                       = :sequential,
    callback_enter::Vector{<:Function} = Function[],
    callback_exit::Vector{<:Function}  = Function[]
) = Group(Vector{Node}(child_list), child_index_current, parent, mode, callback_enter, callback_exit)

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