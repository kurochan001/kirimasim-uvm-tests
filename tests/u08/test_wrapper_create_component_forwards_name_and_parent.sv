/*
:name: test_wrapper_create_component_forwards_name_and_parent
:description: a component wrapper creates its represented type with the supplied name and parent (IEEE 1800.2-2020 Section 8.3.2.2.2)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.2.2.2 8.2.3.2.1 13.1.3.1 13.1.3.2 8.3.1.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_wrapper_create_component_forwards_name_and_parent.expected
*/
// Install a factory override, then call the base proxy creation method
// and observe the concrete component type, leaf name and actual parent.

module test_wrapper_create_component_forwards_name_and_parent;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    int payload = 7;
    function new(string name="item"); super.new(name); endfunction
  endclass
  class replacement_item extends item;
    `uvm_object_utils(replacement_item)
    function new(string name="replacement_item"); super.new(name); endfunction
  endclass
  class node extends uvm_component;
    `uvm_component_utils(node)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  class replacement_node extends node;
    `uvm_component_utils(replacement_node)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass

  initial begin
    automatic node parent = new("env", null);
    automatic uvm_factory factory = uvm_factory::get();
    automatic uvm_object_wrapper wrapper = node::get_type();
    uvm_component created;
    factory.set_type_override_by_type(node::get_type(), replacement_node::get_type());
    created = wrapper.create_component("child", parent);
    if (created == null) $fatal(1, "component not created");
    $display("UT: type %s leaf %s parent_same %0d full %s", created.get_type_name(),
        created.get_name(),
             created.get_parent() == parent, created.get_full_name());
    $finish;
  end
endmodule
