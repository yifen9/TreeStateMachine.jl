module Operation

export set!, get_function, get_name_list

using ..Model
using ..Builder
using ..Copyer

const OP_REGISTRY = Dict{Symbol, Function}()
const DIR_CORE = joinpath(@__DIR__, "core")

_exist(name::Symbol) = haskey(OP_REGISTRY, name)

function set!(name::Symbol, fn::Function)
    _exist(name) && @warn "Operation `$(name)` overrided"
    OP_REGISTRY[name] = fn
    return nothing
end

function get_function(name::Symbol)
    if(_exist(name))
        return OP_REGISTRY[name]
    else
        error("Operation `$(name)` not found")
    end
end

function get_name_list()
    return collect(keys(OP_REGISTRY))
end

function _load()
    for file in readdir(DIR_CORE)
        endswith(file, ".jl") && include(joinpath(DIR_CORE, file))
    end
end

_load()

end