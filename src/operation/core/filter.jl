function filter(
    root::Union{Model.Node, Vector{Model.Node}, AbstractVector};
    predicate::Function = ( _ -> false )
)::Union{Model.Node, AbstractVector, Nothing}
    if isa(root, Model.Node)
        if isa(root, Model.Leaf)
            return predicate(root) ? root : nothing
        else
            kept = Model.Node[]
            for child in root.child_list
                child_filtered = filter(child; predicate)
                child_filtered !== nothing && push!(kept, child_filtered)
            end
            if isempty(kept) && !predicate(root)
                return nothing
            else
                group_new = Model.Group(
                    kept;
                    parent         = nothing,
                    mode           = root.mode,
                    callback_list  = root.callback_list
                )
                group_new.child_index_current = root.child_index_current
                for child_new in group_new.child_list
                    child_new.parent = WeakRef(group_new)
                end
                return group_new
            end
        end
    elseif isa(root, Vector{Model.Node})
        return [ item for item in root if predicate(item) ]
    else
        return [ filter(item; predicate) for item in root ]
    end
end

set!(:filter, filter)