module Model

export Node, Leaf, Group, equal

include(joinpath("core", "node.jl"))
include(joinpath("core", "leaf.jl"))
include(joinpath("core", "group.jl"))

end