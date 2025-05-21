using Test
using TreeStateMachine

@testset "Operation" begin

    @testset "flatten" begin
        node = Builder.build([1, [2, 3], 4])
        @test Operation.get_function(:flatten)(node)                       == [1, 2, 3, 4]
        @test Operation.get_function(:flatten)([node, node])               == [1, 2, 3, 4, 1, 2, 3, 4]
        @test Operation.get_function(:flatten)([node, [node, node], node]) == [1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]
    end

    @testset "filter" begin
        node = Builder.build([1, [2, 3], 4])
        
        @test Operation.get_function(:flatten)(
            Operation.get_function(:filter)(
                node;
                predicate = (x -> x.value % 2 == 0)
            )
        ) == [2, 4]

        @test Operation.get_function(:flatten)(
            Operation.get_function(:filter)(
                [node,
                 node];
                predicate = (x -> x.value % 2 == 0)
            )
        ) == [2, 4,
              2, 4]

        @test Operation.get_function(:flatten)(
            Operation.get_function(:filter)(
                [node,
                [node, node],
                 node];
                predicate = (x -> x.value % 2 == 0)
            )
        ) == [2, 4,
              2, 4, 2, 4,
              2, 4]
    end

    @testset "build / copy" begin
        node = Builder.build([1, [2, 3], 4])

        @test Operation.get_function(:flatten)(
            Operation.get_function(:build)([1, [2, 3], 4])
        ) == [1, 2, 3, 4]

        @test Model.equal(node, Operation.get_function(:copy)(node))

        @test Operation.get_function(:flatten)(
            Operation.get_function(:build)(
                [node,
                [node,
                    node],
                    node]
            )
        ) == [1, 2, 3, 4,
              1, 2, 3, 4,
              1, 2, 3, 4,
              1, 2, 3, 4]
    end
    
    @testset "dfs" begin
        node = Builder.build([1, [2, 3], 4])

        @test Operation.get_function(:flatten)(
            Operation.get_function(:build)(
                Operation.get_function(:dfs)(
                    node;
                    order = :pre
                )
            )
        ) == [1, 2, 3, 4,
              1, 2, 3,
                 2, 3, 4]

        @test Operation.get_function(:flatten)(
            Operation.get_function(:build)(
                Operation.get_function(:dfs)(
                    node;
                    order = :post
                )
            )
        ) == [1, 2, 3,
                 2, 3, 4,
              1, 2, 3, 4]

        @test Operation.get_function(:flatten)(
            Operation.get_function(:build)(
                Operation.get_function(:filter)(
                    Operation.get_function(:dfs)(
                        node;
                        order = :pre
                    );
                    predicate = (x -> isa(x, Model.Group))
                )
            )
        ) == [1, 2, 3, 4,
                 2, 3   ]

        @test Operation.get_function(:flatten)(
            Operation.get_function(:dfs)(
                node;
                order = :pre
            )
        ) == [1, 2, 3, 4]

        @test Operation.get_function(:flatten)(
            Operation.get_function(:build)(
                Operation.get_function(:filter)(
                    Operation.get_function(:dfs)(
                        node;
                        order = :post
                    );
                    predicate = (x -> isa(x, Model.Group))
                )
            )
        ) == [   2, 3,
              1, 2, 3, 4]

        @test Operation.get_function(:flatten)(
            Operation.get_function(:dfs)(
                node;
                order = :post
            )
        ) == [1, 2, 3, 4]
    end

    @testset "bfs" begin
        node = Builder.build([1, [2, 3], 4])

        @test Operation.get_function(:flatten)(
            Operation.get_function(:build)(
                Operation.get_function(:bfs)(node)
            )
        ) == [1, 2, 3, 4,
              1, 2, 3, 4,
                 2, 3   ]
        
        @test Operation.get_function(:flatten)(
            Operation.get_function(:build)(
                Operation.get_function(:filter)(
                    Operation.get_function(:bfs)(node);
                    predicate = (x -> isa(x, Model.Group))
                )
            )
        ) == [1, 2, 3, 4,
                 2, 3   ]

        @test Operation.get_function(:flatten)(
            Operation.get_function(:bfs)(node)
        ) == [1,       4,
                 2, 3   ]
    end

    @testset "find" begin
        node = Builder.build([1, [2, 3], 4])

        @test Operation.get_function(:flatten)(
            Operation.get_function(:find)(
                node;
                predicate = (x -> (isa(x, Model.Leaf) && x.value in (1, 2)))
            )
        ) == [1, 2]

        @test Operation.get_function(:flatten)(
            Operation.get_function(:find)(
                node;
                predicate = (x -> isa(x, Model.Leaf)),
                limit     = 3
            )
        ) == [1, 2, 3]
    end

    @testset "map" begin
        node = Builder.build([1, [2, 3], 4])

        @test Operation.get_function(:flatten)(
            Operation.get_function(:map)(
                node;
                fn = (
                    x -> begin
                        if isa(x, Model.Leaf)
                            x_new = Operation.get_function(:copy)(x)
                            x_new.value = x_new.value * 2
                            x_new
                        else
                            x
                        end
                    end
                )
            )
        ) == [2, 4, 6, 8]

        @test Operation.get_function(:flatten)(
            Operation.get_function(:map)(
                Operation.get_function(:filter)(
                    node;
                    predicate = (x -> (isa(x, Model.Leaf) && (x.value <= 2)))
                );
                fn = (
                    x -> begin
                        if isa(x, Model.Leaf)
                            x_new = Operation.get_function(:copy)(x)
                            x_new.value = x_new.value * 2
                            x_new
                        else
                            x
                        end
                    end
                )
            )
        ) == [2, 4]
    end

    @testset "fold" begin
        node = Builder.build([1, [2, 3], 4])

        @test Operation.get_function(:fold)(
            node;
            initial = 0,
            fn = ((x, y) -> (isa(y, Model.Leaf) && (x = x + y.value)))
        ) == 9

        @test Operation.get_function(:fold)(node) === nothing
    end

    @testset "path" begin
        node = Builder.build([1, [2, 3], 4])

        path = Operation.get_function(:path)(
            node;
            predicate = (x -> (isa(x, Model.Leaf) && x.value === 3))
        )

        @test path[1][3].parent == WeakRef(path[1][2])
        @test path[1][2].parent == WeakRef(path[1][1])

        @test Operation.get_function(:flatten)(path) == [3]
    end

    @testset "size" begin
        node = Builder.build([1, [2, 3], 4])
        @test Operation.get_function(:size)(node)                                        === 6
        @test Operation.get_function(:size)(node; predicate = (x -> isa(x, Model.Leaf))) === 4
    end

    @testset "height" begin
        leaf = Builder.build(123)
        @test Operation.get_function(:height)(leaf)                                      === 1
        @test Operation.get_function(:height)(Builder.build([leaf]))                     === 2
        @test Operation.get_function(:height)(Builder.build([leaf, leaf]))               === 2
        @test Operation.get_function(:height)(Builder.build([leaf, [leaf, leaf], leaf])) === 3
    end

    @testset "depth" begin
        root   = Builder.build([1, [2, 3], 2])
        @test Operation.get_function(:depth)(root)                                            == [1]
        @test Operation.get_function(:depth)(root; target = root.child_list[2])               == [2]
        @test Operation.get_function(:depth)(root; target = root.child_list[2].child_list[2]) == [3]
        @show Operation.get_function(:depth)(root; target = root.child_list[3])               == [3, 2]
    end
end