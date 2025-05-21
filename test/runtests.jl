using Test
using TreeStateMachine

@testset "Tree State Machine" begin

    @testset "Module" begin
        include(joinpath("module", "test_model.jl"))
        include(joinpath("module", "test_copyer.jl"))
        include(joinpath("module", "test_builder.jl"))
        include(joinpath("module", "test_operation.jl"))
        include(joinpath("module", "test_serialization.jl"))
    end
end