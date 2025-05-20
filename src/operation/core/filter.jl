function filter(node::Union{Vector{Model.Node}, Model.Node}; predicate::Function=( _ -> false ))
    if isa(node, Vector{Model.Node})
        return [ item for item in node if predicate(item) ]
    else
        if isa(node, Model.Leaf)
            return predicate(node) ? node : nothing
        else
            kept = Model.Node[]
            for child in node.child_list
                child_filtered = filter(child; predicate)
                child_filtered !== nothing && push!(kept, child_filtered)
            end
            if isempty(kept) && !predicate(node)
                return nothing
            else
                group_new = Model.Group(kept;
                    parent         = nothing,
                    mode           = node.mode,
                    callback_enter = node.callback_enter,
                    callback_exit  = node.callback_exit
                )
                group_new.child_index_current = node.child_index_current
                for child in group_new.child_list
                    isa(child.parent, WeakRef) && (child_new.parent = WeakRef(group_new))
                end
                return group_new
            end
        end
    end
end

set!(:filter, filter)