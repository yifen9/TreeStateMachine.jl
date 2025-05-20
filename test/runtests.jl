using Test
using TreeStateMachine

@testset "Tree State Machine tests" begin

    @testset "Module tests" begin
        # include(joinpath("module", "test_model.jl"))
        # include(joinpath("module", "test_builder.jl"))
        # include(joinpath("module", "test_copyer.jl"))
        # include(joinpath("module", "test_serialization.jl"))
        include(joinpath("module", "test_operation.jl"))
    end
end