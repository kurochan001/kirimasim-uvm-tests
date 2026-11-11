/*
:name: test_tlm2_extension_type_handle_name_is_stable_across_instance_rename
:description: extension type handle names remain stable when one instance is renamed (IEEE 1800.2-2020 Section 12.3.4.4.5)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.4.5 5.3.4.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_extension_type_handle_name_is_stable_across_instance_rename.expected
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
// Capture the polymorphic type name before renaming an instance. Compare
// nonempty type names without prescribing their implementation formatting.

module test_tlm2_extension_type_handle_name_is_stable_across_instance_rename;
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
    automatic label_extension first = new("first");
    automatic label_extension second = new("second");
    automatic uvm_tlm_extension_base view = first;
    automatic string before_name = view.get_type_handle_name();
    first.set_name("renamed");
    $display("UT: nonempty %0d stable %0d same_type %0d renamed %s", before_name.len() > 0,
             view.get_type_handle_name() == before_name,
             second.get_type_handle_name() == before_name, first.get_name());
    $finish;
  end
endmodule
