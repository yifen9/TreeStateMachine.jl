using Test
using TreeStateMachine.Engine

@testset "Serialization" begin

    @testset "Node <-> NamedTuple <-> Dict <-> JSON" begin
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

    @testset ".dot" begin
        node = Builder.build([1, [2, 3], 4])
        @test Serialization.dot_export(node) ==
"""digraph Tree {
  node [shape=circle, fontsize=8];
  edge [arrowhead=none];
  N1 [label="Group"];
  N1 -> N2;
  N1 -> N3;
  N1 -> N4;
  N2 [label="1"];
  N3 [label="Group"];
  N3 -> N5;
  N3 -> N6;
  N5 [label="2"];
  N6 [label="3"];
  N4 [label="4"];
}"""
        # Serialization.dot_export(node; path="test.dot")
        # run(`dot -Tsvg test.dot -o tree.svg`)
    end
end