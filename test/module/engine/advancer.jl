using Test
using TreeStateMachine.Engine
using TreeStateMachine.Engine.Model

@testset "Advancer" begin

    @testset ":sequential" begin
        root = Builder.build([1, [2, 3], 4])

        Callback.set!(:x2,    (x -> x.value     *= 2))
        Callback.set!(:x3,    (x -> x.value     *= 3))
        Callback.set!(:first, (x -> x.child_list = [x.child_list[1]]))
        root.child_list[1].callback_list[:enter] = [:x2]
        root.child_list[1].callback_list[:exit]  = [:x3]
        root.child_list[2].callback_list[:enter] = [:first]

        Advancer.advance!(root)

        @test root.child_index_current                === 4
        @test root.child_list[1].value                === 6
        @test length(root.child_list[2].child_list)   === 1
        @test Operation.get_function(:flatten)(root)  ==  [6, 2, 4]
        @test root.status                             === :done
        @test root.child_list[1].status               === :done
        @test root.child_list[2].status               === :done
        @test root.child_list[3].status               === :done
        @test root.child_list[2].child_list[1].status === :done
    end

    @testset ":parallel" begin
        root = Builder.build([1, [2, 3], 4])

        Callback.set!(:x4,    (x -> x.value     *= 4))
        Callback.set!(:x5,    (x -> x.value     *= 5))
        root.child_list[1].callback_list[:enter] = [:x4]
        root.child_list[1].callback_list[:exit]  = [:x5]
        root.child_list[3].callback_list[:enter] = [:x4]
        root.child_list[3].callback_list[:exit]  = [:x5]

        root.mode = :parallel

        Advancer.advance!(root)

        @test Operation.get_function(:flatten)(root) == [20, 2, 3, 80]

        @test root.child_index_current === 1
    end
end