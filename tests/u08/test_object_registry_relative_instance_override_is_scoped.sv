/*
:name: test_object_registry_relative_instance_override_is_scoped
:description: an object registry instance override is relative to its supplied parent (IEEE 1800.2-2020 Section 8.2.4.2.6)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.2.4.2.6 8.2.4.2.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_registry_relative_instance_override_is_scoped.expected
*/
// The registry prefixes the override path with the parent full name.
// Creating the same leaf under another parent leaves the base type selected.

module test_object_registry_relative_instance_override_is_scoped;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class owner extends uvm_component;
    `uvm_component_utils(owner)
    function new(string name, uvm_component parent=null); super.new(name, parent); endfunction
  endclass

  class base_item extends uvm_object;
    `uvm_object_utils(base_item)
    function new(string name="base_item"); super.new(name); endfunction
  endclass
  class first_item extends base_item;
    `uvm_object_utils(first_item)
    function new(string name="first_item"); super.new(name); endfunction
  endclass
  class second_item extends base_item;
    `uvm_object_utils(second_item)
    function new(string name="second_item"); super.new(name); endfunction
  endclass

  initial begin
    automatic owner parent = new("env");
    automatic owner other = new("other");
    base_item selected;
    base_item outside;
    base_item::type_id::set_inst_override(first_item::get_type(), "packet", parent);
    selected = base_item::type_id::create("packet", parent);
    outside = base_item::type_id::create("packet", other);
    $display("UT: selected %s outside %s", selected.get_type_name(), outside.get_type_name());
    $display("UT: leaf names %s %s", selected.get_name(), outside.get_name());
    $finish;
  end
endmodule
