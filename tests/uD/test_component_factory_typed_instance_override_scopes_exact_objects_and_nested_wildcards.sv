/*
:name: test_component_factory_typed_instance_override_scopes_exact_objects_and_nested_wildcards
:description: component factory typed instance override scopes exact objects and nested wildcards
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.2.1.4 D.2.1.1 D.2.1.2 13.1.8 8.3.1.4.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_factory_typed_instance_override_scopes_exact_objects_and_nested_wildcards.expected
*/
module test_component_factory_typed_instance_override_scopes_exact_objects_and_nested_wildcards;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class item_base extends uvm_object;
    `uvm_object_utils(item_base)
    function new(string name="item"); super.new(name); endfunction
  endclass
  class item_a extends item_base;
    `uvm_object_utils(item_a)
    function new(string name="a"); super.new(name); endfunction
  endclass
  class item_b extends item_base;
    `uvm_object_utils(item_b)
    function new(string name="b"); super.new(name); endfunction
  endclass
  class comp_base extends uvm_component;
    `uvm_component_utils(comp_base)
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  class comp_a extends comp_base;
    `uvm_component_utils(comp_a)
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  class owner_actor extends uvm_component;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  function automatic void register_types();
    void'(item_base::get_type()); void'(item_a::get_type()); void'(item_b::get_type());
    void'(comp_base::get_type()); void'(comp_a::get_type());
  endfunction
  initial begin
    automatic owner_actor owner=new("owner47",null);
    automatic owner_actor nested=new("nested",owner);
    automatic owner_actor peer=new("peer47",null);
    uvm_object selected,other,outside;
    uvm_component chosen_comp,peer_comp;
    register_types();
    owner.set_inst_override_by_type("chosen",item_base::get_type(),item_a::get_type());
    owner.set_inst_override_by_type("nested.*",comp_base::get_type(),comp_a::get_type());
    selected=owner.create_object("item_base","chosen");
    other=owner.create_object("item_base","other");
    outside=peer.create_object("item_base","chosen");
    chosen_comp=nested.create_component("comp_base","leaf");
    peer_comp=peer.create_component("comp_base","leaf");
    $display("UT: helper_instance selected %0d other %0d outside %0d nested %0d peer %0d",
             selected.get_type_name()=="item_a",other.get_type_name()=="item_base",
             outside.get_type_name()=="item_base",chosen_comp.get_type_name()=="comp_a",
             peer_comp.get_type_name()=="comp_base");
    $display("UT: helper_instance_parent %0d",chosen_comp.get_parent()==nested);
    $finish;
  end
endmodule
