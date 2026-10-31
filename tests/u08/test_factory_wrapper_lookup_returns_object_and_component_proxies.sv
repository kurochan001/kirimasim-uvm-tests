/*
:name: test_factory_wrapper_lookup_returns_object_and_component_proxies
:description: registered names resolve to their exact object and component wrapper handles (IEEE 1800.2-2020 Section 8.3.1.7.2)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.7.2 8.3.1.3 8.3.1.7.3 8.3.1.7.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_wrapper_lookup_returns_object_and_component_proxies.expected
*/
// Compare wrappers through the common uvm_object_wrapper base type.
// No numeric IDs or global registration counts are prescribed.

module test_factory_wrapper_lookup_returns_object_and_component_proxies;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class base_item extends uvm_object;
    `uvm_object_utils(base_item)
    function new(string name="base_item"); super.new(name); endfunction
  endclass
  class replacement_item extends base_item;
    `uvm_object_utils(replacement_item)
    function new(string name="replacement_item"); super.new(name); endfunction
  endclass
  class other_item extends uvm_object;
    `uvm_object_utils(other_item)
    function new(string name="other_item"); super.new(name); endfunction
  endclass

  class leaf_component extends uvm_component;
    `uvm_component_utils(leaf_component)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass

  initial begin
    automatic uvm_default_factory factory = new;
    automatic uvm_object_wrapper object_type = base_item::get_type();
    automatic uvm_object_wrapper component_type = leaf_component::get_type();
    factory.register(object_type);
    factory.register(component_type);
    $display("UT: object_same %0d component_same %0d distinct %0d",
        factory.find_wrapper_by_name("base_item") == object_type,
             factory.find_wrapper_by_name("leaf_component") == component_type,
                 object_type != component_type);
    $display("UT: names_registered %0d %0d types_registered %0d %0d",
        factory.is_type_name_registered("base_item"),
             factory.is_type_name_registered("leaf_component"),
                 factory.is_type_registered(object_type),
                     factory.is_type_registered(component_type));
    $finish;
  end
endmodule
