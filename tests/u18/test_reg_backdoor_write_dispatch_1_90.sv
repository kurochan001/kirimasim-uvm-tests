/*
:name: test_reg_backdoor_write_dispatch_1_90
:description: reg backdoor write dispatch 1 checks independently derived manager or printed backdoor contracts
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.6.11 18.4.1 19.1.1.1 19.1.1.2.1 19.1.1.2.2 19.1.1.2.3 19.1.1.2.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:files: helpers90_write/write_fixture90.svh
:incdirs: helpers90_write
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_backdoor_write_dispatch_1_90.expected
*/
// Original override observes the printed virtual task through a base receiver.
// This is declaration/dispatch evidence, not built-in DPI or physical DUT
// write evidence.
module test_reg_backdoor_write_dispatch_1_90;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  localparam int MODE=1;
  localparam int LAYOUT=1;
  localparam string CASE_NAME="reg_backdoor_write_dispatch_1";
  `include "write_fixture90.svh"
  initial begin #5000; $fatal(1,"manager/backdoor90 watchdog"); end
endmodule
