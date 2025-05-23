module Serialization

export to_namedtuple, to_dict, json_export, json_import, dot_export

using JSON

using ..Engine
using ..Operation

function _dict_normalize!(dict::Dict{String, Any}, map::Dict{String, <:Function})
    for (key, value) in dict
        haskey(map, key) && (dict[key] = map[key](value))
        if isa(dict[key], Dict{String, Any})
            _dict_normalize!(dict[key], map)
        elseif isa(dict[key], AbstractVector)
            for item in dict[key]
                isa(item, Dict{String, Any}) && _dict_normalize!(item, map)
            end
        end
    end
    return dict
end

function to_namedtuple(data::Union{AbstractVector, Model.Node, Dict{String, Any}})
    if isa(data, AbstractVector)
        return [ to_namedtuple(item) for item in data ]
    elseif isa(data, Model.Node)
        if isa(data, Model.Leaf)
            return (
                value         = data.value,
                status        = data.status,
                parent        = isa(data.parent, WeakRef) ? true : false,
                callback_list = data.callback_list
            )
        else
            child_namedtuple = [ to_namedtuple(child) for child in data.child_list ]
            return (
                child_list          = child_namedtuple,
                child_index_current = data.child_index_current,
                mode                = data.mode,
                status              = data.status,
                parent              = isa(data.parent, WeakRef) ? true : false,
                callback_list       = data.callback_list
            )
        end
    else
        if haskey(data, "child_list")
            data_child_list = data["child_list"]
            if isa(data_child_list, AbstractVector)
                child_list = [ to_namedtuple(child) for child in data_child_list ]
                return (
                    child_list          = child_list,
                    child_index_current = data["child_index_current"],
                    mode                = data["mode"],
                    status              = data["status"],
                    parent              = data["parent"],
                    callback_list       = data["callback_list"]
                )
            else
                error("Group dict[:child_list] must be a Vector")
            end
        else
            if haskey(data, "value")
                return (
                    value          = data["value"],
                    status         = data["status"],
                    parent         = data["parent"],
                    callback_list  = data["callback_list"]
                )
            else
                error("Empty Leaf value")
            end
        end
    end
end

function to_dict(data::Union{AbstractVector, Model.Node, NamedTuple})
    if isa(data, AbstractVector)
        return [ to_dict(item) for item in data ]
    elseif isa(data, Model.Node)
        return to_dict(to_namedtuple(data))
    else
        key_leaf  = (:value, :status, :parent, :callback_list)
        key_group = (:child_list, :child_index_current, :mode, :status, :parent, :callback_list)

        key_list = Tuple(keys(data))
        if key_list == key_leaf
            return Dict(
                "value"         => data.value,
                "status"        => data.status,
                "parent"        => data.parent,
                "callback_list" => data.callback_list
            )
        elseif key_list == key_group
            return Dict(
                "child_list"          => [ to_dict(item) for item in data.child_list ],
                "child_index_current" => data.child_index_current,
                "mode"                => data.mode,
                "status"              => data.status,
                "parent"              => data.parent,
                "callback_list"       => data.callback_list
            )
        else
            error("to_dict: NamedTuple keys \"$(keys(data))\" unexpected")
        end
    end
end

function json_export(data::Union{Model.Node, NamedTuple, Dict{String, Any}}; path::Union{AbstractString, Nothing}=nothing)
    dict = begin
        if isa(data, Model.Node)
            to_dict(to_namedtuple(data))
        elseif isa(data, NamedTuple)
            to_dict(data)
        else
            data
        end
    end
    _dict_normalize!(dict, Dict("parent" => (v -> isa(v, Bool) ? v : (isa(v, WeakRef) ? true : false))))
    if path === nothing
        return JSON.json(dict)
    else
        open(path, "w") do io
            write(io, json_export(dict))
        end
        return nothing
    end
end

function json_import(source::AbstractString; return_type::Type=Dict{String,Any})
    text = isfile(source) ? read(source, String) : source
    dict = JSON.parse(text)

    _dict_normalize!(dict, Dict(
        "mode"          => (v -> isa(v, String)            ? Symbol(v)                       : v),
        "status"        => (v -> isa(v, String)            ? Symbol(v)                       : v),
        "parent"        => (v -> Bool(v)),
        "callback_list" => (v -> isa(v, Dict{String, Any}) ? Dict{Symbol, Vector{Symbol}}(v) : v)
    ))

    if return_type === Dict{String,Any} || return_type === Dict
        return dict
    elseif return_type === NamedTuple
        return to_namedtuple(dict)
    elseif return_type === Model.Node || return_type <: Model.Node
        return Builder.build(to_namedtuple(dict))
    else
        error("return_type: \"$return_type\" not supported")
    end
end

function dot_export(root::Model.Node; path::Union{AbstractString, Nothing}=nothing, shape::String="circle", fontsize::Int=8, arrowhead::String="none")
    result = String[]
    push!(result, "digraph Tree {")
    push!(result, "  node [shape=$shape, fontsize=$fontsize];")
    push!(result, "  edge [arrowhead=$arrowhead];")

    let counter = Ref(0), ids = Dict{Model.Node, String}()
        getid = node -> begin
            if !haskey(ids, node)
                counter[] += 1
                ids[node] = "N$(counter[])"
            end
            ids[node]
        end

        for node in Operation.get_function(:dfs)(root)
            id = getid(node)
            label = isa(node, Model.Leaf) ? string(node.value) : "Group"
            push!(result, "  $id [label=\"$(label)\"];")

            if node isa Model.Group
                for child in node.child_list
                    cid = getid(child)
                    push!(result, "  $id -> $cid;")
                end
            end
        end
    end

    push!(result, "}")

    if path === nothing
        return join(result, "\n")
    else
        open(path, "w") do io
            write(io, join(result, "\n"))
        end
        return nothing
    end
end

end