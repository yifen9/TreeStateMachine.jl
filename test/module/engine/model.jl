using Test
using TreeStateMachine.Engine

@testset "Model" begin

    @testset "Constructor" begin

        @testset "Leaf" begin

            @testset "Default" begin
                leaf = Model.Leaf(123)

                @test isa(leaf, Model.Leaf{Int})

                @test leaf.value          === 123
                @test leaf.status         === :idle
                @test leaf.parent         === nothing
                @test leaf.callback_list  ==  Dict()
            end

            @testset "Custom" begin
                parent = WeakRef(Model.Leaf(123))

                leaf = Model.Leaf(
                    "abc";
                    status = :running,
                    parent,
                    callback_list = Dict(
                        :enter => Symbol[],
                        :exit  => Symbol[]
                    )
                )

                @test leaf.value         === "abc"
                @test leaf.status        === :running
                @test leaf.parent        === parent
                @test leaf.callback_list ==  Dict(
                    :enter => Symbol[],
                    :exit  => Symbol[]
                )
            end

            @testset "Error" begin
                @test_throws MethodError Model.Leaf()
            end
        end

        @testset "Group" begin
            
            @testset "Default" begin
                leaf_1 = Model.Leaf("a")
                leaf_2 = Model.Leaf("b")

                group = Model.Group([leaf_1, leaf_2])

                @test isa(group, Model.Group)

                @test group.child_list          ==  [leaf_1, leaf_2]
                @test group.child_index_current === 1
                @test group.mode                === :sequential
                @test group.status              === :idle
                @test group.parent              === nothing
                @test group.callback_list       ==  Dict()
            end

            @testset "Custom" begin
                leaf_1 = Model.Leaf("a")
                leaf_2 = Model.Leaf("b")

                parent = WeakRef(Model.Group([leaf_1]))

                group = Model.Group(
                    [leaf_2];
                    mode          = :parallel,
                    status        = :running,
                    parent,
                    callback_list = Dict(
                        :enter => Symbol[],
                        :exit  => Symbol[]
                    )
                )

                @test group.child_list          ==  [leaf_2]
                @test group.child_index_current === 1
                @test group.mode                === :parallel
                @test group.status              === :running
                @test group.parent              === parent
                @test group.callback_list       ==  Dict(
                    :enter => Symbol[],
                    :exit  => Symbol[]
                )
            end

            @testset "Error" begin
                @test_throws MethodError Model.Group()
            end
        end

        @testset "Mixed" begin
            leaf     = Model.Leaf(123)
            group_l  = Model.Group([leaf])
            group_lg = Model.Group([leaf, group_l])

            @test isa(group_lg.child_list[1], Model.Leaf)
            @test isa(group_lg.child_list[2], Model.Group)

            @test group_lg.child_list          ==  [leaf, group_l]
            @test group_lg.child_index_current === 1
            @test group_lg.mode                === :sequential
            @test group_lg.status              === :idle
            @test group_lg.parent              === nothing
            @test group_lg.callback_list       ==  Dict()
        end
    end

    @testset "Equal" begin
        
        @testset "Leaf" begin
            
            @testset "Single" begin
                leaf_0 = Model.Leaf(0)
                leaf_1 = Model.Leaf(123)
                leaf_2 = Model.Leaf(123)
                leaf_3 = Model.Leaf(123; parent        = WeakRef(leaf_0))
                leaf_4 = Model.Leaf(123; callback_list = Dict(:enter => Symbol[]))
                leaf_5 = Model.Leaf(123; callback_list = Dict(:exit  => Symbol[]))
                leaf_6 = Model.Leaf(123; callback_list = Dict(:exit  => Symbol[:f1]))
                leaf_7 = Model.Leaf(123; callback_list = Dict(:exit  => Symbol[:f2]))

                @test !Model.equal(leaf_0, leaf_1)
                @test  Model.equal(leaf_1, leaf_2)
                @test !Model.equal(leaf_1, leaf_3)
                @test !Model.equal(leaf_1, leaf_4)
                @test !Model.equal(leaf_1, leaf_5)
                @test !Model.equal(leaf_4, leaf_5)
                @test !Model.equal(leaf_5, leaf_6)
                @test !Model.equal(leaf_6, leaf_7)
            end

            @testset "Vector" begin
                leaf_0 = Model.Leaf(0)
                leaf_1 = Model.Leaf(123)
                leaf_2 = Model.Leaf(123)

                leaf_list_0  = [leaf_0]
                leaf_list_1  = [leaf_1]
                leaf_list_2  = [leaf_2]

                leaf_list_01 = [leaf_0, leaf_1]
                leaf_list_10 = [leaf_1, leaf_0]
                leaf_list_11 = [leaf_1, leaf_1]

                @test !Model.equal(leaf_list_0,  leaf_list_1)
                @test  Model.equal(leaf_list_1,  leaf_list_2)
                @test !Model.equal(leaf_list_01, leaf_list_10)
                @test !Model.equal(leaf_list_1,  leaf_list_11)
            end
        end

        @testset "Group" begin
            
            @testset "Single" begin
                leaf_0   = Model.Leaf(0)
                leaf_1   = Model.Leaf(123)
                leaf_2   = Model.Leaf(123)

                group_0  = Model.Group([leaf_0])

                group_00 = Model.Group([leaf_0, leaf_0])
                group_11 = Model.Group([leaf_1, leaf_1])
                group_22 = Model.Group([leaf_2, leaf_2])
                group_01 = Model.Group([leaf_0, leaf_1])
                group_10 = Model.Group([leaf_1, leaf_0])
                group_33 = Model.Group([leaf_1, leaf_1]; parent        = WeakRef(group_0))
                group_44 = Model.Group([leaf_1, leaf_1]; callback_list = Dict(:enter => Symbol[]))
                group_55 = Model.Group([leaf_1, leaf_1]; callback_list = Dict(:exit  => Symbol[]))
                group_66 = Model.Group([leaf_1, leaf_1]; callback_list = Dict(:exit  => Symbol[:f1]))
                group_77 = Model.Group([leaf_1, leaf_1]; callback_list = Dict(:exit  => Symbol[:f2]))

                @test !Model.equal(group_0,  group_00)
                @test !Model.equal(group_00, group_11)
                @test  Model.equal(group_11, group_22)
                @test !Model.equal(group_01, group_10)
                @test !Model.equal(group_11, group_33)
                @test !Model.equal(group_11, group_44)
                @test !Model.equal(group_11, group_55)
                @test !Model.equal(group_44, group_55)
                @test !Model.equal(group_55, group_66)
                @test !Model.equal(group_66, group_77)
            end

            @testset "Vector" begin
                group_0 = Model.Group([Model.Leaf(0)])
                group_1 = Model.Group([Model.Leaf(123)])
                group_2 = Model.Group([Model.Leaf(123)])

                group_list_0  = [group_0]
                group_list_1  = [group_1]
                group_list_2  = [group_2]

                group_list_00 = [group_0, group_0]
                group_list_01 = [group_0, group_1]
                group_list_10 = [group_1, group_0]

                @test !Model.equal(group_list_0,  group_list_00)
                @test !Model.equal(group_list_0,  group_list_1)
                @test  Model.equal(group_list_1,  group_list_2)
                @test !Model.equal(group_list_01, group_list_10)
            end
        end

        @testset "Mixed" begin
            
            @testset "Single" begin
                leaf   = Model.Leaf(0)
                group  = Model.Group([leaf])
                @test !Model.equal(leaf, group)
            end

            @testset "Vector" begin
                leaf   = Model.Leaf(0)
                group  = Model.Group([leaf])

                node_list_l = [leaf]
                node_list_g = [group]

                node_list_lg = [leaf,  group]
                node_list_gl = [group, leaf]

                @test !Model.equal(node_list_l,  node_list_g)
                @test !Model.equal(node_list_l,  node_list_lg)
                @test  Model.equal(node_list_lg, node_list_lg)
                @test !Model.equal(node_list_lg, node_list_gl)
            end
        end
    end
end