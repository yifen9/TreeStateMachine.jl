function find(
    root::Union{Model.Node, Vector{Model.Node}};
    predicate::Function        = ( _ -> false ),
    limit::Union{Int, Nothing} = nothing,
    search::Symbol             = :dfs,
    order::Symbol              = :pre
)::Vector{Model.Node}
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
    result = Model.Node[]
    for node in node_list
        if predicate(node)
            push!(result, node)
            (limit !== nothing && length(result) >= limit) && break
        end
    end
    return result
end

set!(:find, find)