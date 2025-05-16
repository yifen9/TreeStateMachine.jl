module Builder

export build

using ..Model

function build(data::NamedTuple; parent_reference::Bool = true)
    data_parent_reference = haskey(data, :parent) ? data.parent : parent_reference
    data_parent = (data_parent_reference === false) ? nothing : data_parent_reference

    parent = (data_parent === true) ? nothing : data_parent
    callback_enter = get(data, :callback_enter, Function[])
    callback_exit  = get(data, :callback_exit,  Function[])

    if haskey(data, :child_list)
        data_child_list = data.child_list
        if isempty(data_child_list)
            error("Build empty Group")
        else
            mode = get(data, :mode, :sequential)
            group = Model.Group(
                Vector{Node}();
                parent,
                mode,
                callback_enter,
                callback_exit
            )
            for data_child in data_child_list
                child = build(data_child; parent_reference)
                (data_parent_reference !== false) && (child.parent = WeakRef(group))
                push!(group.child_list, child)
            end
            return group
        end
    else
        if haskey(data, :value)
            value = data.value
            if isa(value, AbstractVector)
                isempty(value) && error("Build empty Leaf")
            else
                (value === nothing) && error("Build empty Leaf")
            end
            return Model.Leaf(
                value;
                parent,
                callback_enter,
                callback_exit
            )
        else
            error("Build empty Leaf")
        end
    end
end

build(data::AbstractVector; parent_reference::Bool = true) = build((child_list = data,); parent_reference)

build(data; parent_reference::Bool = true) = build((value = data,); parent_reference)

end