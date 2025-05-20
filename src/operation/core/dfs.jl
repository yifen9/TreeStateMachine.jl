function _dfs!(node::Model.Node, acc::Vector{Model.Node}, order::Symbol)
    (order == :pre)  && push!(acc, node)
    if isa(node, Model.Group)
        for child in node.child_list
            _dfs!(child, acc, order)
        end
    end
    (order == :post) && push!(acc, node)
    return nothing
end

function dfs(root::Model.Node; order::Symbol=:pre)
    if order in (:pre, :post)
        result = Model.Node[]
        _dfs!(root, result, order)
        return result
    else
        error("Order `$(order)` not found in (:pre, :post)")
    end
end

set!(:dfs, dfs)