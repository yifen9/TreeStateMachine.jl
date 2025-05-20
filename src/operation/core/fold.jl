function fold(root::Model.Node; initial::Any=nothing, fn::Function=(x -> x), order::Symbol=:pre)
    acc = initial
    for item in dfs(root; order)
        acc = fn(acc, item)
    end
    return acc
end

set!(:fold, fold)