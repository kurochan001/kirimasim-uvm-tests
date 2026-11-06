/*
:name: test_vreg_reset_killed_write_write_explicit_hard_87
:description: vreg reset killed write write explicit hard observes standard access behavior with independent modeled storage
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.3.5 18.9.1.3.1 18.9.1.3.2 18.9.1.1.2 18.10.2.2 18.6.9.1 18.6.9.2 18.6.7.2 19.5.2.6 19.5.2.7 18.2.3.4 18.2.4.18 1800-2023 6.21 8.20 9.3.2 9.7
:uvm: 2020.3.1
:files: helpers87/killed_access_fixture87.svh
:incdirs: helpers87
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=test87
:expected_exit: 0
:expected_stdout: @test_vreg_reset_killed_write_write_explicit_hard_87.expected
*/
// Independent original testbench storage; no HDL or physical bus protocol.
module test_vreg_reset_killed_write_write_explicit_hard_87;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=3;
  localparam string CASE_NAME="vreg_reset_killed_write_write_explicit_hard";
  localparam bit EXPLICIT_KIND=1;
  `include "killed_access_fixture87.svh"
  initial run_test("test87");
  initial begin #5000; $fatal(1,"access87 watchdog"); end
endmodule
