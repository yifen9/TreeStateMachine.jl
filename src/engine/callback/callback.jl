module Callback

export set!, get_function, get_name_list, run

using ..Model

const REGISTRY = Dict{Symbol, Function}()

_exist(name::Symbol)::Bool = haskey(REGISTRY, name)

function set!(name::Symbol, fn::Function)::Nothing
    _exist(name) && @warn "Callback `$(name)` overrided"
    REGISTRY[name] = fn
    return nothing
end

function get_function(name::Symbol)::Function
    if(_exist(name))
        return REGISTRY[name]
    else
        error("Callback `$(name)` not found")
    end
end

function get_name_list()::Vector{Symbol}
    return collect(keys(REGISTRY))
end

function run(node::Model.Node, name::Symbol)::Nothing
    callback_list = node.callback_list
    if haskey(callback_list, name)
        callback_list_name = callback_list[name]
        for callback in callback_list_name
            get_function(callback)(node)
        end
    end
end

end