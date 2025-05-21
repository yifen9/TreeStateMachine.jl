mutable struct Leaf{T} <: Node
    value::T
    parent::Union{WeakRef, Nothing}
    callback_enter::Vector{Function}
    callback_exit::Vector{Function}
end

Leaf(
    value::T;
    parent::Union{WeakRef, Nothing}    = nothing,
    callback_enter::Vector{<:Function} = Function[],
    callback_exit::Vector{<:Function}  = Function[]
) where T = Leaf{T}(
    value,
    parent,
    Vector{Function}(callback_enter),
    Vector{Function}(callback_exit)
)

function equal(a::Leaf, b::Leaf)::Bool
    return a.value == b.value &&
           typeof(a.parent) === typeof(b.parent) &&
           a.callback_enter == b.callback_enter &&
           a.callback_exit  == b.callback_exit
end

function equal(leaf_a::Vector{<:Leaf}, leaf_b::Vector{<:Leaf})::Bool
    if length(leaf_a) === length(leaf_b)
        leaf_zip = zip(leaf_a, leaf_b)
        for (leaf_a_item, leaf_b_item) in leaf_zip
            !equal(leaf_a_item, leaf_b_item) && return false
        end
        return true
    else
        return false
    end
end