size(
    root::Union{Model.Node, Vector{Model.Node}};
    predicate::Function = ( _ -> true ),
    search::Symbol      = :dfs,
    order::Symbol       = :pre
)::Int = length(find(root; predicate, search, order))

set!(:size, size)