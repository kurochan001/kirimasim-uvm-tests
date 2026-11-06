/*
:name: test_mam_description_states_1_90
:description: mam description states 1 checks independently derived manager or printed backdoor contracts
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.6.1 18.12.5.1 18.12.5.3 18.12.5.4 18.12.6.2 18.12.7.2.1 18.12.7.2.2 18.12.7.2.5 1800-2023 6.21 8.20 20.6.1
:uvm: 2020.3.1
:files: helpers90_description/description_fixture90.svh
:incdirs: helpers90_description
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mam_description_states_1_90.expected
*/
// Qualified state-description observation: occupied-state strings are nonempty
// and change between selected allocation states; no spelling, layout or
// address parser is fixed.
module test_mam_description_states_1_90;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  localparam int MODE=1;
  localparam int LAYOUT=1;
  localparam string CASE_NAME="mam_description_states_1";
  `include "description_fixture90.svh"
  initial begin #5000; $fatal(1,"manager/backdoor90 watchdog"); end
endmodule
