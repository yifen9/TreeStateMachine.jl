module Model

export Node, Leaf, Group

using AbstractTrees

include(joinpath("core", "Node.jl"))
include(joinpath("core", "Leaf.jl"))
include(joinpath("core", "Group.jl"))

end