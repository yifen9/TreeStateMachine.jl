abstract type Node end

function equal(node_a::Node, node_b::Node)
    if typeof(node_a) === typeof(node_b)
        return equal(node_a, node_b)
    else
        return false
    end
end

function equal(node_a::Vector{<:Node}, node_b::Vector{<:Node})
    if length(node_a) === length(node_b)
        for (node_a_item, node_b_item) in zip(node_a, node_b)
            (typeof(node_a_item) !== typeof(node_b_item) || !equal(node_a_item, node_b_item)) && return false
        end
        return true
    else
        return false
    end
end