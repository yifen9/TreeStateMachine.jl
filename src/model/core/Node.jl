abstract type Node end

function equal(node_a::Node, node_b::Node)::Bool
    if typeof(node_a) === typeof(node_b)
        return equal(node_a, node_b)
    else
        return false
    end
end

function equal(node_a::Vector{<:Node}, node_b::Vector{<:Node})::Bool
    if length(node_a) === length(node_b)
        ndoe_zip = zip(node_a, node_b)
        for (node_a_item, node_b_item) in ndoe_zip
            (typeof(node_a_item) !== typeof(node_b_item) || !equal(node_a_item, node_b_item)) && return false
        end
        return true
    else
        return false
    end
end