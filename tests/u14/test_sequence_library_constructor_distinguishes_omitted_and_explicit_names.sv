/*
:name: test_sequence_library_constructor_distinguishes_omitted_and_explicit_names
:description: sequence library construction preserves the standard empty default and explicit names (14.4.3)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.3 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_constructor_distinguishes_omitted_and_explicit_names.expected
*/
// What it checks:
// 1. The sequence library constructor uses its specified default name when the
//    name argument is omitted.
// 2. The sequence library constructor preserves an explicitly supplied
//    instance name.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.4.3 (UVM-SEQUENCE-LIBRARY-CONSTRUCTOR-DEFAULT-NAME) gives
//    rule 1 above. Setup: Independent instances are constructed with omitted
//    and explicit name arguments. Expected: The omitted-name instance has an
//    empty name.
// 2. 1800.2-2020 14.4.3 (UVM-SEQUENCE-LIBRARY-CONSTRUCTOR-EXPLICIT-NAME) gives
//    rule 2 above. Setup: Independent instances are constructed with omitted
//    and explicit name arguments. Expected: The explicit name is named_library
//    and an explicitly empty name remains empty.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// No static registrations or sequence selection are requested.
// The default control calls the library constructor without a name.
module test_sequence_library_constructor_distinguishes_omitted_and_explicit_names;
  import uvm_pkg::*;
  initial begin
    automatic uvm_sequence_library#(uvm_sequence_item) omitted = new();
    automatic uvm_sequence_library#(uvm_sequence_item) named = new("named_library");
    automatic uvm_sequence_library#(uvm_sequence_item) explicit_empty = new("");
    $display("UT: default_empty %0d explicit_name %s explicit_empty %0d",
             omitted.get_name() == "", named.get_name(), explicit_empty.get_name() == "");
    $display("UT: distinct %0d %0d", omitted != named, named != explicit_empty);
    $finish;
  end
endmodule
