/*
:name: test_root_finish_disabled_returns_to_caller_88
:description: root finish disabled returns to caller checks independently derived public observations
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.7.3.4 F.7.3.4 F.7.3.5 F.7.3.1 F.7.2.2 13.1.4.2.1 13.1.4.1.8 9.8.1 1800-2023 6.21 8.18 8.20
:uvm: 2020.3.1
:files: helpers88/finish_fixture88.svh
:incdirs: helpers88
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_root_finish_disabled_returns_to_caller_88.expected
*/
module test_root_finish_disabled_returns_to_caller_88;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam string CASE_NAME="root_finish_disabled_returns_to_caller";
  localparam int MODE=3;
  `include "finish_fixture88.svh"
  initial begin #5000; $fatal(1,"root or predictor88 watchdog"); end
endmodule
