function flatten(
    root::Union{Model.Node, Vector{Model.Node}, AbstractVector};
    search::Symbol = :dfs,
    order::Symbol  = :pre
)::AbstractVector
    result = Any[]
    if isa(root, Model.Node) || isa(root, Vector{Model.Node})
        node_list = if isa(root, Model.Node)
            if search in (:dfs, :bfs)
                if search === :dfs
                    dfs(root; order)
                else
                    bfs(root)
                end
            else
                error("Search `$(search)` not found in (:dfs, :bfs)")
            end
        else
            root
        end
        for node in node_list
            isa(node, Model.Leaf) && push!(result, node.value)
        end
        return result
    else
        for root_item in root
            append!(result, flatten(root_item; search, order))
        end
        return result
    end
end

set!(:flatten, flatten)