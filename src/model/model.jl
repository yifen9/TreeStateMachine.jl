module Model

export Node, Leaf, Group, equal

using AbstractTrees

include(joinpath("core", "node.jl"))
include(joinpath("core", "leaf.jl"))
include(joinpath("core", "group.jl"))

function equal(a::Vector{Node}, b::Vector{Node})
    for (item_a, item_b) in (a, b)
        (typeof(item_a) === typeof(item_b) && equal(item_a, item_b)) || return false
    end
    return true
end

end