module Serialization

export to_namedtuple, to_dict, json_export, json_import

using AbstractTrees
using JSON3

using ..Model
using ..Builder

function _dict_normalize!(dict::Dict{String, Any}, map::Dict{String, Function})
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

function to_namedtuple(data::Union{Model.Node, Dict{String, Any}})
    if isa(data, Model.Node)
        if isa(data, Model.Leaf)
            return (
                value          = data.value,
                parent         = data.parent,
                callback_enter = data.callback_enter,
                callback_exit  = data.callback_exit,
            )
        else
            child_namedtuple = [ to_namedtuple(child) for child in data.child_list ]
            return (
                child_list          = child_namedtuple,
                child_index_current = data.child_index_current,
                parent              = data.parent,
                mode                = data.mode,
                callback_enter      = data.callback_enter,
                callback_exit       = data.callback_exit,
            )
        end
    else
        if haskey(data, "child_list")
            data_child_list = data["child_list"]
            if isa(data_child_list, AbstractVector)
                child_list = [ to_namedtuple(child) for child in data_child_list ]
                return (
                    child_list          = child_list,
                    child_index_current = get(data, "child_index_current", 1),
                    parent              = get(data, "parent", nothing),
                    mode                = get(data, "mode", :sequential),
                    callback_enter      = get(data, "callback_enter", Function[]),
                    callback_exit       = get(data, "callback_exit",  Function[])
                )
            else
                error("Group dict[:child_list] must be a Vector")
            end
        else
            if haskey(data, "value")
                return (
                    value          = data["value"],
                    parent         = get(data, "parent", nothing),
                    callback_enter = get(data, "callback_enter", Function[]),
                    callback_exit  = get(data, "callback_exit",  Function[])
                )
            else
                error("Empty Leaf value")
            end
        end
    end
end

function to_dict(data::Union{Model.Node, NamedTuple})
    if isa(data, Model.Node)
        return to_dict(to_namedtuple(data))
    else
        key_leaf  = (:value, :parent, :callback_enter, :callback_exit)
        key_group = (:child_list, :child_index_current, :parent, :mode, :callback_enter, :callback_exit)

        key_list = Tuple(keys(data))
        if key_list == key_leaf
            return Dict(
                "value"          => data.value,
                "callback_enter" => data.callback_enter,
                "callback_exit"  => data.callback_exit
            )
        elseif key_list == key_group
            return Dict(
                "child_list"          => [ to_dict(item) for item in data.child_list ],
                "child_index_current" => data.child_index_current,
                "parent"              => data.parent,
                "mode"                => data.mode,
                "callback_enter"      => data.callback_enter,
                "callback_exit"       => data.callback_exit
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
    if path === nothing
        return JSON3.write(dict)
    else
        open(path, "w") do io
            write(io, json_export(dict))
        end
        return nothing
    end
end

function json_import(source::AbstractString; return_type::Type=Dict{String,Any})
    text = isfile(source) ? read(source, String) : source
    dict = JSON3.read(text, Dict{String, Any})
    _dict_normalize!(dict, Dict(
        "mode"           => (v -> isa(v, String) ? Symbol(v) : v),
        "callback_enter" => (v -> isa(v, Vector{Function}) ? v : Vector{Function}(v)),
        "callback_exit"  => (v -> isa(v, Vector{Function}) ? v : Vector{Function}(v))
    ))
    if return_type === Dict{String,Any}
        return dict
    elseif return_type === NamedTuple
        return to_namedtuple(dict)
    elseif return_type === Model.Node || return_type <: Model.Node
        return Builder.build(to_namedtuple(dict))
    else
        error("return_type: \"$return_type\" not supported")
    end
end

end