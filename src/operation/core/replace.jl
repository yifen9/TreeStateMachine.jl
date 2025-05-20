function replace(root::Model.Node; predicate::Function=( _ -> false ), fn::Function=(x -> x))
    if predicate(root)
        return fn(root)
    else
        if isa(root, Model.Leaf)
            return copy(root)
        else
            group_new = copy(root)

            child_list_new = Model.Node[]
            for child in root.child_list
                child_new = replace(child; predicate, fn)
                if child_new === nothing
                    continue
                else
                    push!(child_list_new, child_new)
                    isa(child_new.parent, WeakRef) && (child_new.parent = WeakRef(group_new))
                end
            end
            group_new.child_list = child_list_new

            return group_new
        end
    end
end