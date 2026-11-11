/*
:name: test_callback_constructor_default_selected_and_empty_names_preserve_object_identity
:description: callback constructor default selected and empty names preserve object identity (IEEE 1800.2-2020 Section 10.7.1.2.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.1.2.1 10.7.1.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_callback_constructor_default_selected_and_empty_names_preserve_object_identity.expected
*/
// What it checks:
// 1. The callback constructor provides its declared optional name.
// 2. A callback derives from the object base.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.7.1.2.1 (UVM-OBJECTION-CB-REVIEW-CALLBACK-NAMES) gives
//    rule 1 above. Setup: Construct omitted, selected and explicitly empty
//    names. Expected: The names match the declared default, selected name and
//    empty string.
// 2. 1800.2-2020 10.7.1.1 (UVM-OBJECTION-CB-REVIEW-CALLBACK-OBJECT-BASE) gives
//    rule 2 above. Setup: Assign a selected callback to an object view.
//    Expected: The view retains identity.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe the declared optional callback name and object base. No initial
// enable state, omitted mode argument, registration or callback dispatch is
// inferred.
module test_callback_constructor_default_selected_and_empty_names_preserve_object_identity;
  import uvm_pkg::*;
  initial begin
    automatic uvm_callback omitted = new();
    automatic uvm_callback named = new("selected");
    automatic uvm_callback empty = new("");
    automatic uvm_object base_view = named;
    $display("UT: callback_constructor default %0d named %0d empty %0d object %0d",
             omitted.get_name() == "uvm_callback",named.get_name() == "selected",
             empty.get_name() == "",base_view == named);
    $finish;
  end
endmodule
