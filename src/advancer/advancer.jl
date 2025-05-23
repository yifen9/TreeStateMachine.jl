module Advancer

export Callback, Mode, advance

using ..Model

include(joinpath("callback", "callback.jl"))
include(joinpath("mode",     "mode.jl"))

advance(root::Model.Node) = nothing

end