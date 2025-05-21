function _dfs!(
    root::Model.Node,
    result::Vector{Model.Node},
    order::Symbol
)::Nothing
    (order == :pre)  && push!(result, root)
    if isa(root, Model.Group)
        for child in root.child_list
            _dfs!(child, result, order)
        end
    end
    (order == :post) && push!(result, root)
    return nothing
end

function dfs(
    root::Model.Node;
    order::Symbol = :pre
)::Vector{Model.Node}
    if order in (:pre, :post)
        result = Model.Node[]
        _dfs!(root, result, order)
        return result
    else
        error("Order `$(order)` not found in (:pre, :post)")
    end
end

set!(:dfs, dfs)