using Test
using TreeStateMachine

@testset "Tree State Machine tests" begin

    @testset "Module tests" begin
        include(joinpath("module", "test_model.jl"))
        include(joinpath("module", "test_builder.jl"))
    end

end