function fold(
    root::Union{Model.Node, Vector{Model.Node}};
    initial::Any   = nothing,
    fn::Function   = ((x, y) -> x),
    search::Symbol = :dfs,
    order::Symbol  = :pre
)::Union{Any, Nothing}
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
    result = initial
    for node in node_list
        result = fn(result, node)
    end
    return result
end

set!(:fold, fold)