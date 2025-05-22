using Test
using TreeStateMachine

@testset "Copyer" begin

    @testset "Leaf" begin
        leaf_origin = Model.Leaf(
            123;
            callback_list = Dict(
                :enter => Symbol[],
                :exit  => Symbol[]
            )
        )
        leaf_copy = Copyer.copy(leaf_origin)

        @test Model.equal(leaf_origin, leaf_copy)
    end

    @testset "Group" begin
        leaf = Model.Leaf(123)
        group_origin = Model.Group(
            [leaf, leaf];
            callback_list = Dict(
                :enter => Symbol[],
                :exit  => Symbol[]
            )
        )
        group_copy = Copyer.copy(group_origin)

        @test Model.equal(group_origin, group_copy)
    end

    @testset "Mixed" begin
        leaf            = Model.Leaf(123)
        group_g         = Model.Group([leaf])
        group_lg_origin = Model.Group([leaf, group_g])
        group_lg_copy   = Copyer.copy(group_lg_origin)
        @test Model.equal(group_lg_origin, group_lg_copy)
    end
end