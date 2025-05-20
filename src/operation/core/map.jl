function map(
    root::Model.Node;
    fn::Function = (x -> x),
    order::Symbol = :pre
)
    result = Any[]
    for item in dfs(root; order)
        push!(result, fn(item))
    end
    return result
end

set!(:map, map)