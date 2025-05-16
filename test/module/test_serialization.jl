using Test
using TreeStateMachine

using JSON3

@testset "Serialization module" begin

    @testset "to_namedtuple" begin

        @testset "Leaf → NamedTuple" begin
            leaf = Model.Leaf(7; parent=nothing, callback_enter=[x -> x], callback_exit=[x -> x])

            leaf_nt = Serialization.to_namedtuple(leaf)

            @test isa(leaf_nt, NamedTuple)

            @test haskey(leaf_nt, :value) && leaf_nt.value == 7
            @test haskey(leaf_nt, :parent) && leaf_nt.parent === false
            @test haskey(leaf_nt, :callback_enter) && leaf_nt.callback_enter == leaf.callback_enter
            @test haskey(leaf_nt, :callback_exit)  && leaf_nt.callback_exit  == leaf.callback_exit
        end

        @testset "Group → NamedTuple" begin
            leaf_a = Model.Leaf("a")
            leaf_b = Model.Leaf("b")

            group = Model.Group([leaf_a, leaf_b]; parent=nothing, mode=:parallel, callback_enter=[x -> x], callback_exit=[x -> x])
            group.child_index_current = 2
            group_nt = Serialization.to_namedtuple(group)

            @test isa(group_nt, NamedTuple)

            @test haskey(group_nt, :child_list)
            @test length(group_nt.child_list) == 2
            @test [ child.value for child in group_nt.child_list ] == ["a", "b"]

            @test haskey(group_nt, :child_index_current) && group_nt.child_index_current == 2

            @test haskey(group_nt, :parent) && group_nt.parent === false
            @test haskey(group_nt, :mode) && group_nt.mode == :parallel
            @test haskey(group_nt, :callback_enter) && group_nt.callback_enter == group.callback_enter
            @test haskey(group_nt, :callback_exit)  && group_nt.callback_exit  == group.callback_exit
        end

        @testset "Dict → NamedTuple" begin
            leaf_a = Model.Leaf("a")
            leaf_b = Model.Leaf("b")

            group = Model.Group([leaf_a, leaf_b]; parent=nothing, mode=:parallel, callback_enter=[x -> x], callback_exit=[x -> x])
            group.child_index_current = 2

            group_dict = Serialization.to_dict(group)
            group_nt = Serialization.to_namedtuple(group_dict)

            @test isa(group_nt, NamedTuple)

            @test haskey(group_nt, :child_list)
            @test length(group_nt.child_list) == 2
            @test [ child.value for child in group_nt.child_list ] == ["a", "b"]

            @test haskey(group_nt, :child_index_current) && group_nt.child_index_current == 2

            @test haskey(group_nt, :parent) && group_nt.parent === false
            @test haskey(group_nt, :mode) && group_nt.mode == :parallel
            @test haskey(group_nt, :callback_enter) && group_nt.callback_enter == group.callback_enter
            @test haskey(group_nt, :callback_exit)  && group_nt.callback_exit  == group.callback_exit
        end
    end

    @testset "to_dict" begin

        @testset "Leaf NamedTuple → Dict" begin
            leaf_nt = (
                value          = 1,
                parent         = nothing,
                callback_enter = Function[],
                callback_exit  = Function[]
            )
            leaf_dict = Serialization.to_dict(leaf_nt)

            @test isa(leaf_dict, Dict{String, Any})

            @test leaf_dict["value"] == 1
            @test haskey(leaf_dict, "callback_enter") && leaf_dict["callback_enter"] == Function[]
            @test haskey(leaf_dict, "callback_exit")  && leaf_dict["callback_exit"]  == Function[]
        end

        @testset "Group NamedTuple → Dict" begin
            group_nt = (
                child_list          = [(value=10, parent=nothing, callback_enter=Function[], callback_exit=Function[])],
                child_index_current = 1,
                parent              = nothing,
                mode                = :sequential,
                callback_enter      = Function[],
                callback_exit       = Function[]
            )
            group_dict = Serialization.to_dict(group_nt)
            inner = group_dict["child_list"][1]

            @test isa(group_dict, Dict{String, Any})

            @test haskey(group_dict, "child_list")
            @test isa(group_dict["child_list"], Vector)

            @test group_dict["mode"] == :sequential
            @test isa(inner, Dict{String,Any})

            @test inner["value"] == 10
        end

        @testset "Node → Dict" begin

            @testset "Leaf" begin
                leaf = Model.Leaf(3)
                leaf_dict = Serialization.to_dict(leaf)

                @test isa(leaf_dict, Dict{String, Any})
                @test leaf_dict["value"] == 3
            end

            @testset "Group" begin
                group = Model.Group([ Model.Leaf(1), Model.Leaf(2) ])
                group_dict = Serialization.to_dict(group)

                @test isa(group_dict, Dict{String, Any})
                @test haskey(group_dict, "child_list")

                @test isa(group_dict["child_list"], Vector)
                @test [ child["value"] for child in group_dict["child_list"] ] == [1, 2]
            end
        end
    end

    @testset "json_export / json_import" begin

        @testset "Dict → JSON → Dict" begin
            dict = Dict("x"=>10, "y"=>["a", "b"])
            json_string = Serialization.json_export(dict)
            json_parsed = Serialization.json_import(json_string)

            @test json_parsed == dict
        end

        @testset "Leaf NamedTuple → JSON → Dict" begin
            nt = (value=42, parent=nothing, callback_enter=Function[], callback_exit=Function[])
            json_nt = Serialization.json_export(nt)
            dict_nt = Serialization.json_import(json_nt)

            @test isa(json_nt, String)
            @test dict_nt["value"] == 42
        end

        @testset "Node → JSON → Dict" begin
            leaf = Model.Leaf("hi")
            leaf_json = Serialization.json_export(leaf)
            leaf_dict = Serialization.json_import(leaf_json)

            @test leaf_dict["value"] == "hi"
        end

        @testset "return_type NamedTuple" begin
            nt_cfg = (child_list = [(value = 10,)],)
            tree = Builder.build(nt_cfg)
            dict = Serialization.to_dict(tree)
            nt_default = Serialization.json_import(Serialization.json_export(dict))
            nt = Serialization.json_import(Serialization.json_export(dict); return_type=NamedTuple)

            @test isa(nt_default, Dict{String,Any})
            @test isa(nt, NamedTuple)
        end

        @testset "return_type Node" begin
            nt_cfg = (child_list = [(value = 10,)],)
            tree = Builder.build(nt_cfg)
            json_str = Serialization.json_export(tree)

            tree2 = Serialization.json_import(json_str; return_type=Model.Node)

            @test isa(tree2, Model.Group)
            @test length(tree2.child_list) == 1
            @test isa(tree2.child_list[1], Model.Leaf)
            @test tree2.child_list[1].value == 10
        end

        @testset "file path variant" begin
            dict = Dict("x"=>10, "y"=>["a", "b"])
            path = tempname() * ".json"
            Serialization.json_export(dict; path)

            file_dict = Serialization.json_import(path)

            rm(path; force=true)

            @test file_dict == dict
        end
    end

    @testset "Complex" begin
        node = Builder.build([1, [2, 3], 4])

        nt_from_node = Serialization.to_namedtuple(node)
        dict_from_node = Serialization.to_dict(node)
        dict_from_nt = Serialization.to_dict(nt_from_node)
        node_from_nt = Builder.build(nt_from_node)
        node_from_dict = Builder.build(Serialization.to_namedtuple(dict_from_nt))
        nt_from_dict = Serialization.to_namedtuple(dict_from_nt)

        @test isa(node, Model.Node)
        @test isa(nt_from_node, NamedTuple)
        @test isa(dict_from_node, Dict)
        @test isa(dict_from_nt, Dict)
        @test isa(node_from_nt, Model.Node)
        @test isa(node_from_dict, Model.Node)
        @test isa(nt_from_dict, NamedTuple)

        @test Model.equal(node, node_from_nt) && Model.equal(node, node_from_dict)
        @test nt_from_node == nt_from_dict
        @test dict_from_node == dict_from_nt

        @test Model.equal(node, Serialization.json_import(Serialization.json_export(node); return_type=Model.Node))
        @test nt_from_node == Serialization.json_import(Serialization.json_export(nt_from_node); return_type=NamedTuple)
        @test dict_from_node == Serialization.json_import(Serialization.json_export(dict_from_node); return_type=Dict)
    end
end