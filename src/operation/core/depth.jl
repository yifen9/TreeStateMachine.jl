function depth(
    root::Union{Model.Node, Vector{Model.Node}};
    target::Model.Node = isa(root, Model.Node) ? root : root[1],
    search::Symbol     = :dfs,
    order::Symbol      = :pre
)::Vector{Int}
    path_list = path(root; predicate = (x -> Model.equal(x, target)), search, order)
    return [ length(item) for item in path_list ]
end

set!(:depth, depth)