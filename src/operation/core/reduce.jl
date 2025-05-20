function reduce(node::AbstractVector; fn::Function=(x -> x))
    if isempty(node)
        error("Reduce on empty collection")
    else
        acc = first(node)
        for item in Iterators.rest(node)
            acc = fn(acc, item)
        end
        return acc
    end
end

set!(:reduce, reduce)