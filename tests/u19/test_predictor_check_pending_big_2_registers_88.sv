/*
:name: test_predictor_check_pending_big_2_registers_88
:description: predictor check pending big 2 registers checks independently derived public observations
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.3.3.3 19.3.2.1 19.3.2.2 19.3.2.3 19.3.2.4 19.2.1.2.5 19.2.1.2.6 18.4.4.15 18.4.2.2 18.5.3.2 18.2.3.3 18.2.3.6 18.2.5.2 6.6.5 6.6.3.2 1800-2023 6.21 8.18 8.20
:uvm: 2020.3.1
:files: helpers88/predictor_check_fixture88.svh
:incdirs: helpers88
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_predictor_check_pending_big_2_registers_88.expected
*/
module test_predictor_check_pending_big_2_registers_88;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam string CASE_NAME="predictor_check_pending_big_2_registers";
  localparam bit BIG_ENDIAN=1;
  localparam int PENDING_REGISTERS=2;
  `include "predictor_check_fixture88.svh"
  initial begin #5000; $fatal(1,"root or predictor88 watchdog"); end
endmodule
