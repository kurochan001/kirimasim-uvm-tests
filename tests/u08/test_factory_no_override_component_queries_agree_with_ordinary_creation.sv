/*
:name: test_factory_no_override_component_queries_agree_with_ordinary_creation
:description: lookup without any override selects the registered wrapper used by ordinary creation (IEEE 1800.2-2020 Section 8.3.1.7.1)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.7.1 8.3.1.7.2 8.3.1.7.3 8.3.1.7.4 B.2.1
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_no_override_component_queries_agree_with_ordinary_creation.expected
*/
// Install no overrides. Both lookup spellings must agree with creation.
module test_factory_no_override_component_queries_agree_with_ordinary_creation;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class original_component extends uvm_component;
    `uvm_component_utils(original_component)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  initial begin
    uvm_factory factory;
    uvm_object_wrapper original;
    original_component parent;
    uvm_component made;
    parent = new("parent", null);
    factory = uvm_factory::get();
    original = original_component::get_type();
    made = factory.create_component_by_name("original_component", "env", "leaf", parent);
    $display("UT: by_type %0d by_name %0d created %0d",
             factory.find_override_by_type(original, "env.leaf") == original,
             factory.find_override_by_name("original_component", "env.leaf") == original,
             made != null && made.get_object_type() == original);
    $finish;
  end
endmodule
