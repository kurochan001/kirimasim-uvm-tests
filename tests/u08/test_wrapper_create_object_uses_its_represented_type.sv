/*
:name: test_wrapper_create_object_uses_its_represented_type
:description: an object wrapper directly creates its represented type despite a factory override (IEEE 1800.2-2020 Section 8.3.2.2.1)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.2.2.1 8.2.4.2.1 8.3.1.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_wrapper_create_object_uses_its_represented_type.expected
*/
// Exercise the proxy creation method at the factory boundary. Unlike
// registry create, this method allocates the type represented by the proxy.

module test_wrapper_create_object_uses_its_represented_type;
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
    automatic uvm_factory factory = uvm_factory::get();
    automatic uvm_object_wrapper wrapper = item::get_type();
    uvm_object created;
    factory.set_type_override_by_type(item::get_type(), replacement_item::get_type());
    created = wrapper.create_object("direct");
    if (created == null) $fatal(1, "object not created");
    $display("UT: type %s name %s", created.get_type_name(), created.get_name());
    $finish;
  end
endmodule
