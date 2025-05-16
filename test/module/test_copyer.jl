using Test
using TreeStateMachine

@testset "Copyer module" begin

    @testset "Leaf" begin
        called = false
        f(x) = (called = true)

        orig = Model.Leaf(
            123;
            parent         = nothing,
            callback_enter = [f],
            callback_exit  = [f]
        )

        dup = Copyer.copy(orig)

        @test isa(dup, Model.Leaf{Int})
        @test dup !== orig
        @test dup.value == orig.value

        @test dup.parent === nothing

        @test length(dup.callback_enter) == length(orig.callback_enter)
        @test dup.callback_enter[1] === orig.callback_enter[1]
        @test dup.callback_enter !== orig.callback_enter

        @test length(dup.callback_exit) == length(orig.callback_exit)
        @test dup.callback_exit[1] === orig.callback_exit[1]
        @test dup.callback_exit !== orig.callback_exit
    end

    @testset "Group" begin
        f_enter(x) = nothing
        f_exit(x)  = nothing

        leaf1 = Model.Leaf(1)
        leaf2 = Model.Leaf(2)
        grp_orig = Model.Group(
            [leaf1, leaf2];
            parent         = nothing,
            mode           = :parallel,
            callback_enter = [f_enter],
            callback_exit  = [f_exit]
        )
        grp_orig.child_index_current = 2

        dup_grp = Copyer.copy(grp_orig)

        @test isa(dup_grp, Model.Group)
        @test dup_grp !== grp_orig

        @test dup_grp.mode == grp_orig.mode
        @test dup_grp.callback_enter == grp_orig.callback_enter
        @test dup_grp.callback_exit  == grp_orig.callback_exit
        @test dup_grp.callback_enter !== grp_orig.callback_enter
        @test dup_grp.callback_exit  !== grp_orig.callback_exit

        @test dup_grp.child_index_current == grp_orig.child_index_current

        @test length(dup_grp.child_list) == 2
        @test all(isa(c, Model.Leaf) for c in dup_grp.child_list)
        @test [c.value for c in dup_grp.child_list] == [1, 2]
        @test all(dup_grp.child_list[i] !== grp_orig.child_list[i] for i in 1:2)

        @test all(child.parent === nothing for child in dup_grp.child_list)
    end

end