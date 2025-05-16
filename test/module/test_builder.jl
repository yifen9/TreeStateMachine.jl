using Test
using TreeStateMachine

@testset "Builder module" begin

    @testset "Scalar → Leaf" begin
        leaf = Builder.build(123)

        @test isa(leaf, Model.Leaf{Int})
        
        @test leaf.value == 123
        @test leaf.parent === nothing
        @test leaf.callback_enter == Function[]
        @test leaf.callback_exit  == Function[]
    end
    
    @testset "Vector → Group" begin
        group = Builder.build(["a","b","c"])

        @test isa(group, Model.Group)

        @test length(group.child_list) == 3
        @test all(child.value in ["a","b","c"] for child in group.child_list)
        @test all(isa(child.parent, WeakRef)   for child in group.child_list)

        @test group.mode == :sequential
    end

    @testset "Nested Vector → Nested Groups" begin
        data = [1, [2,3], 4]

        root = Builder.build(data)

        group_2 = root.child_list[2]

        @test isa(root, Model.Group)

        @test isa(group_2, Model.Group)
        @test [leaf.value for leaf in group_2.child_list] == [2,3]
        @test isa(group_2.parent, WeakRef)

        for leaf in group_2.child_list
            @test isa(leaf.parent, WeakRef)
            @test leaf.parent.value === group_2
        end
    end

    @testset "parent_reference = false" begin
        group = Builder.build([1,2,3]; parent_reference=false)

        @test isa(group, Model.Group)

        @test all(child.parent === nothing for child in group.child_list)
    end

    @testset "NamedTuple custom Leaf" begin
        enter_called = false
        exit_called  = false

        f1(x) = (enter_called = true)
        f2(x) = (exit_called  = true)

        data = (
            value          = "x",
            parent         = nothing,
            callback_enter = [f1],
            callback_exit  = [f2]
        )

        leaf = Builder.build(data)

        @test isa(leaf, Model.Leaf{String})

        @test leaf.value == "x"
        @test leaf.parent === nothing
        @test length(leaf.callback_enter) == 1
        @test leaf.callback_enter[1] === f1
        @test length(leaf.callback_exit) == 1
        @test leaf.callback_exit[1] === f2
    end

    @testset "NamedTuple custom Group" begin
        g_enter = false
        g_exit  = false
        f_enter(x) = (g_enter = true)
        f_exit(x)  = (g_exit  = true)

        data = (
            child_list     = [10, 20],
            parent         = nothing,
            mode           = :parallel,
            callback_enter = [f_enter],
            callback_exit  = [f_exit],
        )

        group = Builder.build(data)

        @test isa(group, Model.Group)

        @test [child.value for child in group.child_list] == [10,20]
        @test all(child.parent == group for child in group.child_list)

        @test group.parent === nothing
        @test group.mode == :parallel
        @test group.callback_enter == [f_enter]
        @test group.callback_exit  == [f_exit]
    end

    @testset "Mixed nested NamedTuple & Vector" begin
        data = (
            child_list = [
                1,
                (
                    child_list = [2,3],
                    mode       = :parallel
                ),
                4
            ],
            mode = :sequential
        )

        root = Builder.build(data)

        @test isa(root, Model.Group)
        @test root.mode == :sequential

        @test isa(root.child_list[2], Model.Group)
        @test root.child_list[2].mode == :parallel

        @test [leaf.value for leaf in root.child_list[2].child_list] == [2,3]
    end

    @testset "Error cases" begin
        @test_throws ErrorException Builder.build([],)
        @test_throws ErrorException Builder.build((;),)
    end
end