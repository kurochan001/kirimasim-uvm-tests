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
