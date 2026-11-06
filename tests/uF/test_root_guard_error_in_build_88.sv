/*
:name: test_root_guard_error_in_build_88
:description: root guard error in build checks independently derived public observations
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.7.3.6 F.7 F.7.3.1 F.7.2.2 6.5.1.2.6 6.6.5 6.6.3.2 6.3.3.3 13.1.4.1.1 13.1.4.1.3 13.1.4.1.4 9.8.1.3 1800-2023 6.21 8.18 8.20
:uvm: 2020.3.1
:files: helpers88/guard_fixture88.svh
:incdirs: helpers88
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_root_guard_error_in_build_88.expected
*/
module test_root_guard_error_in_build_88;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam string CASE_NAME="root_guard_error_in_build";
  localparam int MODE=0;
  `include "guard_fixture88.svh"
  initial begin #5000; $fatal(1,"root or predictor88 watchdog"); end
endmodule
