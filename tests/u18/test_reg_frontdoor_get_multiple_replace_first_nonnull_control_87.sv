/*
:name: test_reg_frontdoor_get_multiple_replace_first_nonnull_control_87
:description: reg frontdoor get multiple replace first observes standard access behavior with independent modeled storage
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.5.1 18.4.5.2 18.4.4.10 18.4.2.2 18.5.3.2 18.2.3.3 18.2.3.6 18.2.5.2 19.4.2.2.1 19.4.2.3 1800-2023 6.21 8.20 9.3.2 9.7
:uvm: 2020.3.1
:files: helpers87_frontdoor_control/frontdoor_query_fixture87.svh
:incdirs: helpers87_frontdoor_control
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=test87
:expected_exit: 0
:expected_stdout: @test_reg_frontdoor_get_multiple_replace_first_nonnull_control_87.expected
*/
// Independent original testbench storage; no HDL or physical bus protocol.
module test_reg_frontdoor_get_multiple_replace_first_nonnull_control_87;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=2;
  localparam string CASE_NAME="reg_frontdoor_get_multiple_replace_first_nonnull_control";
  `include "frontdoor_query_fixture87.svh"
  initial run_test("test87");
  initial begin #5000; $fatal(1,"access87 watchdog"); end
endmodule
