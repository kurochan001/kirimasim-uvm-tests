/*
:name: test_tlm2_extension_polymorphic_type_handles_distinguish_types_with_same_instance_name
:description: polymorphic extension type handles remain distinct for different types with equal instance names (IEEE 1800.2-2020 Section 12.3.4.4.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.4.4 12.3.4.5.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_extension_polymorphic_type_handles_distinguish_types_with_same_instance_name.expected
*/
// What it checks:
// Polymorphic extension type handles identify a type rather than a named
// instance.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.3.4.4.4 (UVM-EXTENSION-POLYMORPHIC-TYPE-KEY) gives the rule
// above. Setup: Compare same/different types, replace a named instance and
// clear through another same-type key. Expected: Same-type keys remain equal
// across instances/renames and different types remain distinct.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Give two extension types the same instance name and compare their keys
// through common base handles. Instance naming must not merge type identity.

module test_tlm2_extension_polymorphic_type_handles_distinguish_types_with_same_instance_name;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class label_extension extends uvm_tlm_extension#(label_extension);
    `uvm_object_utils(label_extension)
    function new(string name="label_extension"); super.new(name); endfunction
  endclass
  class route_extension extends uvm_tlm_extension#(route_extension);
    `uvm_object_utils(route_extension)
    function new(string name="route_extension"); super.new(name); endfunction
  endclass

  initial begin
    automatic label_extension first = new("same");
    automatic route_extension second = new("same");
    automatic uvm_tlm_extension_base first_view = first;
    automatic uvm_tlm_extension_base second_view = second;
    $display("UT: names_same %0d keys_distinct %0d", first.get_name() == second.get_name(),
             first_view.get_type_handle() != second_view.get_type_handle());
    $finish;
  end
endmodule
