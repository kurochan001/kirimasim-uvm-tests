/*
:name: test_hdl_max_width_parameter_matches_the_default_macro_value
:description: hdl max width parameter matches the default macro value (IEEE 1800.2-2020 Section 19.6.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.6.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_hdl_max_width_parameter_matches_the_default_macro_value.expected
*/
// What it checks:
// 1. The HDL maximum-width parameter defaults to the selected macro value.
// 2. The HDL maximum-width parameter has the declared integer type.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 19.6.1 (UVM-REG-PIPELINE-HDL-PARAMETER-MACRO-DEFAULT) gives
//    rule 1 above. Setup: Inspect the public parameter with omitted and
//    explicitly configured macros under no-DPI execution. Expected: The
//    parameter equals its macro in omitted configuration and an explicit 256
//    configuration.
// 2. 1800.2-2020 19.6.1 (UVM-REG-PIPELINE-HDL-PARAMETER-INTEGER-TYPE) gives
//    rule 2 above. Setup: Inspect the public parameter with omitted and
//    explicitly configured macros under no-DPI execution. Expected: Both
//    selected configurations expose the declared 32-bit integer parameter.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe the declared integer parameter and its macro-derived default. The
// omitted configuration does not fix the implementation macro numeric default.
// The explicit 256 configuration is parameter-only with no DPI/backend. It
// does not certify actual HDL accesses or change the separate backend ABI.
module test_hdl_max_width_parameter_matches_the_default_macro_value;
  import uvm_pkg::*;
  initial begin
    $display("UT: hdl_width_parameter matches_macro %0d integer_bits %0d",
             UVM_HDL_MAX_WIDTH == `UVM_HDL_MAX_WIDTH,
           $bits(UVM_HDL_MAX_WIDTH));
    $finish;
  end
endmodule
