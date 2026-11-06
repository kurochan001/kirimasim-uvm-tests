/*
:name: test_vreg_callback_field_post_read_standalone_slice_status_86
:description: Virtual callback field_post_read_standalone_slice_status checks actual public dispatch and preserved modeled storage
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.10.5.4 18.9.1.4.1 18.9.1.4.2 18.9.1.4.3 18.9.1.4.4 18.9.2.2.1 18.9.2.2.2 18.9.2.2.3 18.9.2.2.4 18.10.5.1 18.10.5.2 18.10.5.3 18.10.6.2.1 18.10.6.2.2 18.10.6.2.3 18.10.6.2.4 18.9.1.1.2 18.10.2.1 18.10.2.2 18.9.1.3.1 18.9.1.3.2 18.10.4.1 18.10.4.2 18.6.9.1 18.6.9.2 18.6.9.3 18.6.9.4 18.6.6.2 18.6.7.2 19.4.2.2.1 19.4.2.3 19.5.2.6 19.5.2.7 D.4.5.9 D.4.5.11 10.7.2.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:files: helpers86/callback_fixture86.svh
:incdirs: helpers86
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=test86
:expected_exit: 0
:expected_stdout: @test_vreg_callback_field_post_read_standalone_slice_status_86.expected
*/
// Original banks provide distinct healthy routes without a physical bus or HDL.
// Literal pre-read order probes keep the incompatible clause readings separate.
module test_vreg_callback_field_post_read_standalone_slice_status_86;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=16;
  localparam string CASE_NAME="field_post_read_standalone_slice_status";
  `include "callback_fixture86.svh"
  initial run_test("test86");
  initial begin #5000; $fatal(1,"virtual callback86 watchdog"); end
endmodule
