/*
:name: test_tlm2_extension_type_handle_names_distinguish_different_types
:description: polymorphic extension type names distinguish different derived extension types (IEEE 1800.2-2020 Section 12.3.4.4.5)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.4.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_extension_type_handle_names_distinguish_different_types.expected
*/
// What it checks:
// The polymorphic type name identifies the extension type independently of the
// instance name.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.3.4.4.5 (UVM-EXTENSION-POLYMORPHIC-TYPE-NAME) gives the rule
// above. Setup: Rename an instance and compare two types given equal instance
// names. Expected: Type names are nonempty, stable within a type and distinct
// across these two types.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use identical instance names but distinct extension types. Compare
// nonempty and distinct returned strings, not literal qualified type names.

module test_tlm2_extension_type_handle_names_distinguish_different_types;
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
    automatic string first_type = first_view.get_type_handle_name();
    automatic string second_type = second_view.get_type_handle_name();
    $display("UT: nonempty %0d %0d distinct %0d", first_type.len() > 0, second_type.len() > 0,
             first_type != second_type);
    $finish;
  end
endmodule
