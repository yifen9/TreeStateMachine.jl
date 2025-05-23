using Test
using TreeStateMachine

@testset "Builder" begin

    @testset "Node" begin
        
        @testset "Leaf" begin
            leaf_c = Model.Leaf(123)
            leaf   = Builder.build(leaf_c)
            @test Model.equal(leaf, leaf_c)
        end

        @testset "Group" begin
            group_c                      = Model.Group([Model.Leaf(123)])
            group                        = Builder.build(group_c)
            group_c.child_list[1].parent = WeakRef(group_c)
            @test Model.equal(group, group_c)
        end

        @testset "Mixed" begin
            leaf_c     = Model.Leaf(123)
            group_l_c  = Model.Group([leaf_c])
            group_lg_c = Model.Group([leaf_c, group_l_c])

            group_lg_c.child_list[1].parent = WeakRef(group_lg_c)
            group_lg_c.child_list[2].parent = WeakRef(group_lg_c)

            group_lg_c.child_list[2].child_list[1].parent = WeakRef(group_lg_c.child_list[2])

            group_lg = Builder.build(group_lg_c)

            @test Model.equal(group_lg, group_lg_c)
        end

        @testset "Error" begin
            group = Model.Group([Model.Leaf(123)])
            group.child_list = Vector{Model.Node}([])
            @test_throws ErrorException Builder.build(group)
        end
    end

    @testset "NamedTuple" begin

        @testset "Leaf" begin

            @testset "Default" begin
                leaf = Builder.build((value = 123,))

                @test isa(leaf, Model.Leaf)

                @test leaf.value         === 123
                @test leaf.status        === :idle
                @test leaf.parent        === nothing
                @test leaf.callback_list ==  Dict()
            end

            @testset "Custom" begin
                leaf_1 = Builder.build((
                    value         = 123,
                    status        = :running,
                    callback_list = Dict(:enter => Symbol[:f1])
                ))
                leaf_2 = Builder.build((
                    value         = 123,
                    callback_list = Dict(:exit => Symbol[:f1, :f2])
                ))
                leaf_3 = Builder.build((
                    value         = 123,
                    callback_list = Dict(
                        :enter => Symbol[:f1],
                        :exit  => Symbol[:f1, :f2]
                    )
                ))
                @test leaf_1.status                === :running
                @test leaf_1.callback_list[:enter] ==  [:f1]
                @test leaf_2.callback_list[:exit]  ==  [:f1, :f2]
                @test leaf_3.callback_list         ==  Dict(:enter => [:f1], :exit => [:f1, :f2])
            end
        end

        @testset "Group" begin
            
            @testset "Default" begin
                leaf_1 = (value = 123,)
                leaf_2 = (value = "abc",)

                group_1 = Builder.build((child_list = [leaf_1, leaf_2],))
                group_2 = Vector{Model.Node}([Builder.build(leaf_1), Builder.build(leaf_2)])

                group_2[1].parent = WeakRef(nothing)
                group_2[2].parent = WeakRef(nothing)

                group_3 = Builder.build((child_list = [leaf_1, group_1],))
                group_4 = Vector{Model.Node}([Builder.build(leaf_1), group_1])

                group_4[1].parent = WeakRef(nothing)
                group_4[2].parent = WeakRef(nothing)

                @test isa(group_1, Model.Group)

                @test Model.equal(group_1.child_list, group_2)
                @test Model.equal(group_3.child_list, group_4)
            end

            @testset "Custom" begin
                leaf = (value = 123,)

                group_1   = Builder.build((child_list=[leaf], callback_list = Dict(:enter => [:f1])))
                group_2   = Builder.build((child_list=[leaf], callback_list = Dict(:exit  => [:f1, :f2]), status = :running))

                group_1_c = Model.Group([Model.Leaf(123)];    callback_list = Dict(:enter => [:f1]))
                group_2_c = Model.Group([Model.Leaf(123)];    callback_list = Dict(:exit  => [:f1, :f2]), status = :running)

                group_1_c.child_list[1].parent = WeakRef(group_1_c)
                group_2_c.child_list[1].parent = WeakRef(group_2_c)

                @test Model.equal(group_1, group_1_c)
                @test Model.equal(group_2, group_2_c)
            end
        end

        @testset "Mixed" begin
            leaf     = (value = 123,)
            group_l  = (child_list = [leaf],)
            group_lg = Builder.build((child_list = [leaf, group_l],))

            leaf_c                          = Model.Leaf(123)
            group_l_c                       = Model.Group([leaf_c])
            group_l_c.child_list[1].parent  = WeakRef(group_l_c)
            group_lg_c                      = Model.Group([leaf_c, group_l_c])
            group_lg_c.child_list[1].parent = WeakRef(group_lg_c)
            group_lg_c.child_list[2].parent = WeakRef(group_lg_c)

            @test Model.equal(group_lg, group_lg_c)
        end

        @testset "Error" begin
            @test_throws ErrorException Builder.build((child_list=[],))
            @test_throws ErrorException Builder.build((;))
        end
    end

    @testset "Any / AbstractVector" begin

        @testset "Leaf" begin
            leaf   = Builder.build(123)
            leaf_c = Model.Leaf(123)
            @test Model.equal(leaf, leaf_c)
        end

        @testset "Group" begin
            group   = Builder.build([1, [2, 3], 4])
            group_c = Model.Group([Model.Leaf(1), Model.Group([Model.Leaf(2), Model.Leaf(3)]), Model.Leaf(4)])

            group_c.child_list[1].parent = WeakRef(group_c)
            group_c.child_list[2].parent = WeakRef(group_c)
            group_c.child_list[3].parent = WeakRef(group_c)

            group_c.child_list[2].child_list[1].parent = WeakRef(group_c.child_list[2])
            group_c.child_list[2].child_list[2].parent = WeakRef(group_c.child_list[2])

            @test Model.equal(group, group_c)
        end
    end
end