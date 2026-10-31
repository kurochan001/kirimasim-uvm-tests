/*
:name: test_factory_instance_override_is_scoped
:description: an instance override takes precedence only at its matching path (IEEE 1800.2-2020 Section 8.3.1.4.1)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.4.1 8.3.1.4.2 8.3.1.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_instance_override_is_scoped.expected
*/
// The factory combines the parent path and requested name for instance
// overrides. A matching instance override precedes the type override.

module test_factory_instance_override_is_scoped;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

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
  uvm_factory factory = uvm_factory::get();
  uvm_object match_item;
  uvm_object other_item;
  factory.set_type_override_by_type(base_item::get_type(), first_item::get_type());
  factory.set_inst_override_by_type(base_item::get_type(), second_item::get_type(), "env.hit");
  match_item = factory.create_object_by_type(base_item::get_type(), "env", "hit");
  other_item = factory.create_object_by_type(base_item::get_type(), "other", "hit");
  $display("UT: matching %s other %s", match_item.get_type_name(), other_item.get_type_name());
  $finish;
end
endmodule
