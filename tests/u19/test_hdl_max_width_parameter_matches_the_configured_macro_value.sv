/*
:name: test_hdl_max_width_parameter_matches_the_configured_macro_value
:description: hdl max width parameter matches the configured macro value (IEEE 1800.2-2020 Section 19.6.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.6.1 1800-2023 6.21
:uvm: 2020.3.1
:uvm_defines: UVM_HDL_MAX_WIDTH=256
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_hdl_max_width_parameter_matches_the_configured_macro_value.expected
*/
// Observe the declared integer parameter and its macro-derived default. The
// omitted configuration does not fix the implementation macro numeric default.
// The explicit 256 configuration is parameter-only with no DPI/backend. It
// does not certify actual HDL accesses or change the separate backend ABI.
module test_hdl_max_width_parameter_matches_the_configured_macro_value;
  import uvm_pkg::*;
  initial begin
    $display("UT: hdl_width_parameter matches_macro %0d integer_bits %0d",
             UVM_HDL_MAX_WIDTH == `UVM_HDL_MAX_WIDTH,
           $bits(UVM_HDL_MAX_WIDTH));
    $finish;
  end
endmodule
