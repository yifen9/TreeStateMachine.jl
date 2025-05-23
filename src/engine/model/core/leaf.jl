mutable struct Leaf{T} <: Node
    value::T
    status::Symbol
    parent::Union{WeakRef, Nothing}
    callback_list::Dict{Symbol, Vector{Symbol}}
end

Leaf(
    value::T;
    status::Symbol                              = :idle,
    parent::Union{WeakRef, Nothing}             = nothing,
    callback_list::Dict{Symbol, Vector{Symbol}} = Dict{Symbol, Vector{Symbol}}()
) where T = Leaf{T}(
    value,
    status,
    parent,
    callback_list
)

function equal(leaf_a::Leaf, leaf_b::Leaf)::Bool
    return leaf_a.value          ==  leaf_b.value          &&
           leaf_a.status         === leaf_b.status         &&
           typeof(leaf_a.parent) === typeof(leaf_b.parent) &&
           leaf_a.callback_list  ==  leaf_b.callback_list
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