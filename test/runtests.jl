using Test
using TreeStateMachine

@testset "Tree State Machine" begin

    @testset "Module" begin

        @testset "Engine" begin
            # include(joinpath("module", "engine", "model.jl"))
            # include(joinpath("module", "engine", "copyer.jl"))
            # include(joinpath("module", "engine", "builder.jl"))
            include(joinpath("module", "engine", "advancer.jl"))
        end
        
        @testset "Operation" begin
            # include(joinpath("module", "operation", "operation.jl"))
        end

        @testset "Util" begin
            # include(joinpath("module", "util", "serialization.jl"))
        end
    end
end