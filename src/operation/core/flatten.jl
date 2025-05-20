function flatten(root::Model.Node)
    all = dfs(root)
    result = Any[]
    for item in all
        isa(item, Model.Leaf) && push!(result, item.value)
    end
    return result
end

set!(:flatten, flatten)