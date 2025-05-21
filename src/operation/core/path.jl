function path(
    root::Union{Model.Node, Vector{Model.Node}};
    predicate::Function        = ( _ -> false ),
    limit::Union{Int, Nothing} = nothing,
    search::Symbol             = :dfs,
    order::Symbol              = :pre
)::Vector{Vector{Model.Node}}
    node_list = find(root; predicate, limit, search, order)
    path_list = Vector{Vector{Model.Node}}()
    for (index, node) in enumerate(node_list)
        limit !== nothing && index > limit && break
        parent = node
        stack = Model.Node[]
        while parent !== nothing
            pushfirst!(stack, parent)
            parent = (parent.parent === nothing) ? nothing : parent.parent.value
        end
        push!(path_list, stack)
    end
    return path_list
end

set!(:path, path)