using Test
using TreeStateMachine

using AbstractTrees

@testset "Model module" begin

    @testset "Leaf" begin

        @testset "Default" begin
            leaf = Model.Leaf(123)

            @test isa(leaf, Model.Leaf{Int})

            @test leaf.value == 123
            @test leaf.parent === nothing
            @test leaf.callback_enter == Function[]
            @test leaf.callback_exit  == Function[]
        end

        @testset "Custom" begin
            dummy = Model.Leaf("x")

            wr = WeakRef(dummy)

            f_enter(x) = global g_enter = true
            f_exit(x)  = global g_exit  = true

            leaf = Model.Leaf(
                "hi";
                parent         = wr,
                callback_enter = [f_enter],
                callback_exit  = [f_exit]
            )

            @test leaf.value == "hi"

            @test isa(leaf.parent, WeakRef)
            @test leaf.parent.value === dummy

            @test length(leaf.callback_enter) == 1
            @test leaf.callback_enter[1] === f_enter
            @test length(leaf.callback_exit)  == 1
            @test leaf.callback_exit[1]  === f_exit
        end
    end

    @testset "Group" begin
        
        @testset "Default" begin
            leaf_a = Model.Leaf("a")
            leaf_b = Model.Leaf("b")

            group = Model.Group([leaf_a, leaf_b])

            @test isa(group, Model.Group)

            @test group.child_list == [leaf_a, leaf_b]
            @test group.child_index_current == 1
            @test group.parent === nothing
            @test group.mode == :sequential
            @test group.callback_enter == Function[]
            @test group.callback_exit  == Function[]
        end

        @testset "Custom" begin
            leaf_a = Model.Leaf("a")
            leaf_b = Model.Leaf("b")

            container = Model.Group([leaf_a])

            wr = WeakRef(container)

            f_enter(x) = global g_enter = true
            f_exit(x)  = global g_exit = true

            group = Model.Group(
                [leaf_b];
                parent         = wr,
                mode           = :parallel,
                callback_enter = [f_enter],
                callback_exit  = [f_exit]
            )

            @test group.child_list == [leaf_b]
            @test group.child_index_current == 1

            @test isa(group.parent, WeakRef)

            @test group.parent.value === container
            @test group.mode == :parallel
            @test group.callback_enter == [f_enter]
            @test group.callback_exit  == [f_exit]
        end
    end

    @testset "AbstractTrees" begin

        @testset "nodevalue" begin
            leaf  = Model.Leaf(1)
            group = Model.Group([leaf])

            @testset "Leaf" begin
                nt = AbstractTrees.nodevalue(leaf)

                @test isa(nt, NamedTuple)

                @test haskey(nt, :value)
                @test nt.value == 1

                @test haskey(nt, :callback_enter)
                @test nt.callback_enter == Function[]

                @test haskey(nt, :callback_exit)
                @test nt.callback_exit == Function[]
            end

            @testset "Group" begin
                nt = AbstractTrees.nodevalue(group)

                @test isa(nt, NamedTuple)

                @test haskey(nt, :child_list)
                @test nt.child_list == group.child_list

                @test haskey(nt, :child_index_current)
                @test nt.child_index_current == group.child_index_current

                @test haskey(nt, :mode)
                @test nt.mode == group.mode

                @test haskey(nt, :callback_enter)
                @test nt.callback_enter == Function[]

                @test haskey(nt, :callback_exit)
                @test nt.callback_exit == Function[]
            end
        end

        @testset "children / childtype" begin
            leaf  = Model.Leaf(1)
            group = Model.Group([leaf])

            @test AbstractTrees.children(leaf) == Any[]
            @test AbstractTrees.children(group) === group.child_list

            @test AbstractTrees.childtype(typeof(leaf)) == Any
            @test AbstractTrees.childtype(typeof(group)) == Model.Node
        end

        @testset "parent" begin
            inner = Model.Leaf("inner")
            outer = Model.Group([inner])

            inner.parent = WeakRef(outer)

            @test isa(inner.parent, WeakRef)

            @test AbstractTrees.parent(inner) === outer
            @test AbstractTrees.parent(outer) === nothing
        end

        @testset "tools" begin
            root = Model.Group([
                Model.Leaf(1),
                Model.Group([
                    Model.Leaf(2),
                    Model.Leaf(3)
                ]),
                Model.Leaf(4)
            ])

            @testset "print_tree" begin
                io = IOBuffer()
                AbstractTrees.print_tree(io, root)
                out = String(take!(io))

                @test occursin("Leaf",  out)
                @test occursin("Group", out)
            end

            @testset "Leaves" begin
                val = collect(AbstractTrees.Leaves(root))
                @test length(val) == 4
            end

            @testset "PreOrderDFS" begin
                val = collect(AbstractTrees.PreOrderDFS(root))
                @test length(val) == 6
            end

            @testset "PostOrderDFS" begin
                val = collect(AbstractTrees.PostOrderDFS(root))
                @test length(val) == 6
            end
        end
    end
end