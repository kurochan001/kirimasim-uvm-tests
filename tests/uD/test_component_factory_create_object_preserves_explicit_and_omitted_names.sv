/*
:name: test_component_factory_create_object_preserves_explicit_and_omitted_names
:description: component factory create object preserves explicit and omitted names
:tags: uD uvm
:type: simulation
:lrm: 1800.2-2020 D.2.1.2 13.1.8 8.3.1.5 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_component_factory_create_object_preserves_explicit_and_omitted_names.expected
*/
module test_component_factory_create_object_preserves_explicit_and_omitted_names;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class item_base extends uvm_object;
    `uvm_object_utils(item_base)
    function new(string name=""); super.new(name); endfunction
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
    uvm_object named_value,default_value;
    item_base first,second;
    register_types(); named_value=owner.create_object("item_base","named47");
    default_value=owner.create_object("item_base");
    $display("UT: helper_objects typed %0d named %0d omitted_empty %0d independent %0d",
             $cast(first,named_value) && $cast(second,default_value),
             named_value.get_name()=="named47",default_value.get_name()=="",
             named_value!=default_value);
    $finish;
  end
endmodule
