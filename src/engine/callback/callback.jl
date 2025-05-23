module Callback

export set!, get_function, get_name_list, run

using ..Model

const REGISTRY = Dict{Symbol, Function}()

_exist(name::Symbol) = haskey(REGISTRY, name)

function set!(name::Symbol, fn::Function)
    _exist(name) && @warn "Callback `$(name)` overrided"
    REGISTRY[name] = fn
    return nothing
end

function get_function(name::Symbol)
    if(_exist(name))
        return REGISTRY[name]
    else
        error("Callback `$(name)` not found")
    end
end

function get_name_list()
    return collect(keys(REGISTRY))
end

function run(node::Model.Node, name::Symbol)
    callback_list = node.callback_list
    if haskey(callback_list, name)
        callback_list_name = callback_list[name]
        for callback in callback_list_name
            get_function(callback)(node)
        end
    end
end

end