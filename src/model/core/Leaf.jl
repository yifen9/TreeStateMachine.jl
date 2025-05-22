mutable struct Leaf{T} <: Node
    value::T
    parent::Union{WeakRef, Nothing}
    callback_list::Dict{Symbol, Vector{Symbol}}
end

Leaf(
    value::T;
    parent::Union{WeakRef, Nothing}             = nothing,
    callback_list::Dict{Symbol, Vector{Symbol}} = Dict{Symbol, Vector{Symbol}}()
) where T = Leaf{T}(
    value,
    parent,
    callback_list
)

function equal(a::Leaf, b::Leaf)::Bool
    return a.value == b.value &&
           typeof(a.parent) === typeof(b.parent) &&
           a.callback_list  == b.callback_list
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