mutable struct Leaf{T} <: Node
    value::T
    parent::Union{WeakRef, Nothing}
    callback_enter::Vector{<:Function}
    callback_exit::Vector{<:Function}
end

Leaf(
    value::T;
    parent::Union{WeakRef, Nothing}    = nothing,
    callback_enter::Vector{<:Function} = Function[],
    callback_exit::Vector{<:Function}  = Function[]
) where T = Leaf{T}(value, parent, callback_enter, callback_exit)

function equal(a::Leaf, b::Leaf)
    return a.value == b.value &&
           typeof(a.parent) == typeof(b.parent) &&
           a.callback_enter == b.callback_enter &&
           a.callback_exit  == b.callback_exit
end

AbstractTrees.nodevalue(leaf::Leaf) = (
    value          = leaf.value,
    callback_enter = leaf.callback_enter,
    callback_exit  = leaf.callback_exit
)

AbstractTrees.children(::Leaf) = Any[]

AbstractTrees.childtype(::Type{Leaf}) = Any

AbstractTrees.parent(leaf::Leaf) = leaf.parent === nothing ? nothing : leaf.parent.value

AbstractTrees.ParentLinks(::Type{Leaf}) = StoredParents()

AbstractTrees.ChildIndexing(::Type{Leaf}) = AbstractTrees.NonIndexedChildren()