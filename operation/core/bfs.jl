function bfs(root::Model.Node)::Vector{Model.Node}
    queue = Model.Node[root]
    result = Model.Node[]
    while !isempty(queue)
        node = popfirst!(queue)
        push!(result, node)
        isa(node, Model.Group) && append!(queue, node.child_list)
    end
    return result
end

set!(:bfs, bfs)