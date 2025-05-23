module Builder

export build

using ..Model
using ..Copyer

build(data::Model.Leaf)::Model.Leaf = Copyer.copy(data)

function build(data::Model.Group)::Model.Group
    data_new = Copyer.copy(data)
    data_new_child_list = data_new.child_list
    if isempty(data_new_child_list)
        error("Build empty Group")
    else
        for data_new_child in data_new_child_list
            data_new_child.parent = WeakRef(data_new)
        end
        return data_new
    end
end

function build(data::NamedTuple)::Model.Node
    status        = get(data, :status,        :idle)
    callback_list = get(data, :callback_list, Dict{Symbol, Vector{Symbol}}())
    if haskey(data, :child_list) && data.child_list !== nothing
        data_child_list = data.child_list
        if isempty(data_child_list)
            error("Build empty Group")
        else
            mode = get(data, :mode, :sequential)
            group = Model.Group(
                Vector{Model.Node}();
                mode,
                status,
                callback_list
            )
            for data_child in data_child_list
                child = build(data_child)
                child.parent = WeakRef(group)
                push!(group.child_list, child)
            end
            return group
        end
    else
        if haskey(data, :value) && data.value !== nothing
            value = data.value
            return Model.Leaf(
                value;
                status,
                callback_list
            )
        else
            error("Build empty Leaf")
        end
    end
end

build(data::AbstractVector)::Model.Group = build((child_list = data,))

build(data::Any)::Model.Leaf = build((value = data,))

end