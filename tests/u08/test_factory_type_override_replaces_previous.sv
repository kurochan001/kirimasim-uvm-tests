/*
:name: test_factory_type_override_replaces_previous
:description: replace one installs a new type override (IEEE 1800.2-2020 Section 8.3.1.4.2)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.4.2 8.3.1.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_type_override_replaces_previous.expected
*/
// Explicitly replacing a type override changes later creations.
// The created instance still receives the requested instance name.

module test_factory_type_override_replaces_previous;
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
  automatic uvm_factory factory = uvm_factory::get();
  uvm_object before_item;
  uvm_object after_item;
  factory.set_type_override_by_type(base_item::get_type(), first_item::get_type());
  before_item = factory.create_object_by_type(base_item::get_type(), "", "before");
  factory.set_type_override_by_type(base_item::get_type(), second_item::get_type(), 1);
  after_item = factory.create_object_by_type(base_item::get_type(), "", "after");
  $display("UT: before %s after %s", before_item.get_type_name(), after_item.get_type_name());
  $display("UT: name %s", after_item.get_name());
  $finish;
end
endmodule
