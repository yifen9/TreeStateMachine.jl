using Test
using TreeStateMachine

using TreeStateMachine.Model

@testset "Serialization module" begin

    @testset "Operations" begin

        @testset "flatten" begin
            node = Builder.build([1, [2, 3], 4])
            @test Operation.get_function(:flatten)(node) == [1, 2, 3, 4]
        end

        @testset "build / copy" begin
            node = Builder.build([1, [2, 3], 4])
            @test Operation.get_function(:flatten)(
                Operation.get_function(:build)([1, [2, 3], 4])) == [1, 2, 3, 4]
            @test Model.equal(node, Operation.get_function(:copy)(node))
            @test Operation.get_function(:flatten)(
                Operation.get_function(:build)([node, [node, node], node])) == [1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]
        end
        
        @testset "dfs" begin
            node = Builder.build([1, [2, 3], 4])
            @test Operation.get_function(:flatten)(
                Operation.get_function(:build)(
                    Operation.get_function(:dfs)(node; order=:pre)))  == [1, 2, 3, 4, 1, 2, 3, 2, 3, 4]
            @test Operation.get_function(:flatten)(
                Operation.get_function(:build)(
                    Operation.get_function(:dfs)(node; order=:post))) == [1, 2, 3, 2, 3, 4, 1, 2, 3, 4]
        end

        @testset "bfs" begin
            node = Builder.build([1, [2, 3], 4])
            @test Operation.get_function(:flatten)(
                Operation.get_function(:build)(
                    Operation.get_function(:bfs)(node))) == [1, 2, 3, 4, 1, 2, 3, 4, 2, 3]
        end

        @testset "find" begin
            node = Builder.build([1, [2, 3], 4])
            @test Operation.get_function(:flatten)(
                Operation.get_function(:build)(
                    Operation.get_function(:find)(
                        node; predicate=(x -> (isa(x, Model.Leaf) && x.value in (1, 2)))
                    )
                )
            ) == [1, 2]
        end

        @testset "map" begin
            node = Builder.build([1, [2, 3], 4])
            @test Operation.get_function(:flatten)(
                Operation.get_function(:build)(
                    Operation.get_function(:map)(
                        node; fn = (x -> (isa(x, Model.Leaf) ? (x.value = x.value * 2) : x))
                    )
                )
            ) == [2, 4, 6, 8, 2, 4, 6, 4, 6, 8]
        end
    end
end