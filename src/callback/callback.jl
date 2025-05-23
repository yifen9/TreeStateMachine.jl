module Callback

export set!, get_function, get_name_list

const REGISTRY = Dict{Symbol, Function}()

_exist(name::Symbol) = haskey(REGISTRY, name)

function set!(name::Symbol, fn::Function)
    _exist(name) && @warn "Operation `$(name)` overrided"
    REGISTRY[name] = fn
    return nothing
end

function get_function(name::Symbol)
    if(_exist(name))
        return REGISTRY[name]
    else
        error("Operation `$(name)` not found")
    end
end

function get_name_list()
    return collect(keys(REGISTRY))
end

end