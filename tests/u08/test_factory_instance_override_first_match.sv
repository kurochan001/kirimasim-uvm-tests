/*
:name: test_factory_instance_override_first_match
:description: instance overrides use the first matching registration (IEEE 1800.2-2020 Section 8.3.1.4.1)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.4.1 8.3.1.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_instance_override_first_match.expected
*/
// Register an exact path before a wildcard. The exact request matches
// both entries and uses the first; another request uses the wildcard.

module test_factory_instance_override_first_match;
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
  uvm_object exact_item;
  uvm_object wildcard_item;
  factory.set_inst_override_by_type(base_item::get_type(), first_item::get_type(), "env.hit");
  factory.set_inst_override_by_type(base_item::get_type(), second_item::get_type(), "env.*");
  exact_item = factory.create_object_by_type(base_item::get_type(), "env", "hit");
  wildcard_item = factory.create_object_by_type(base_item::get_type(), "env", "miss");
  $display("UT: exact %s wildcard %s", exact_item.get_type_name(), wildcard_item.get_type_name());
  $finish;
end
endmodule
