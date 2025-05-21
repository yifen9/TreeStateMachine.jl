function map(
    root::Union{Model.Node, Vector{Model.Node}};
    fn::Function   = (x -> x),
    search::Symbol = :dfs,
    order::Symbol  = :pre
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
        push!(result, fn(node))
    end
    return result
end

set!(:map, map)