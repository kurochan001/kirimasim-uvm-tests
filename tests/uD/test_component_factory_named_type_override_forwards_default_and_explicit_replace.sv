/*
:name: test_component_factory_named_type_override_forwards_default_and_explicit_replace
:description: component factory named type override forwards default and explicit replace
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.2.1.5 D.2.1.2 13.1.8 8.3.1.4.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_factory_named_type_override_forwards_default_and_explicit_replace.expected
*/
module test_component_factory_named_type_override_forwards_default_and_explicit_replace;
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
    uvm_object value;
    register_types();
    uvm_component::set_type_override("item_base","item_a");
    value=owner.create_object("item_base","choice0");
    $display("UT: helper_override 0 correct %0d",value.get_type_name()=="item_a");
    uvm_component::set_type_override("item_base","item_b",0);
    value=owner.create_object("item_base","choice1");
    $display("UT: helper_override 1 correct %0d",value.get_type_name()=="item_b");
    uvm_component::set_type_override("item_base","item_b");
    value=owner.create_object("item_base","choice2");
    $display("UT: helper_override 2 correct %0d",value.get_type_name()=="item_b");
    uvm_component::set_type_override("item_base","item_a",1);
    value=owner.create_object("item_base","choice3");
    $display("UT: helper_override 3 correct %0d",value.get_type_name()=="item_a");
    uvm_component::set_type_override("unregistered_alias47","item_b");
    value=owner.create_object("unregistered_alias47","alias47");
    $display("UT: helper_unregistered_alias %0d",value.get_type_name()=="item_b");
    $finish;
  end
endmodule
