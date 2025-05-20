function find(
    root::Model.Node;     
    predicate::Function = ( _ -> false ),
    order::Symbol = :pre,
    limit::Union{Int, Nothing} = nothing
)
    result = Model.Node[]
    for node in dfs(root; order)
        if predicate(node)
            push!(result, node)
            (limit !== nothing && length(result) >= limit) && break
        end
    end
    return result
end

set!(:find, find)