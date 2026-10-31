/*
:name: test_factory_type_alias_obeys_type_override
:description: creation through a type alias follows the original type override (IEEE 1800.2-2020 Section 8.3.1.6.1)
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.3.1.6.1 8.3.1.4.2 8.3.1.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_type_alias_obeys_type_override.expected
*/
// The alias refers to the original wrapper, so an override for that
// wrapper also applies to a creation request made through its alias.

module test_factory_type_alias_obeys_type_override;
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
  class second_item extends first_item;
    `uvm_object_utils(second_item)
    function new(string name="second_item"); super.new(name); endfunction
  endclass

  initial begin
    automatic uvm_factory factory = uvm_factory::get();
    uvm_object value;
    factory.set_type_alias("m1_alias", base_item::get_type());
    factory.set_type_override_by_type(base_item::get_type(), first_item::get_type());
    value = factory.create_object_by_name("m1_alias", "env", "chosen");
    if (value == null) $fatal(1, "alias creation failed");
    $display("UT: override %s name %s", value.get_type_name(), value.get_name());
    $finish;
  end
endmodule
