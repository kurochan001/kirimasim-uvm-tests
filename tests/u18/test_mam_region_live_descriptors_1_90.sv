/*
:name: test_mam_region_live_descriptors_1_90
:description: mam region live descriptors 1 checks independently derived manager or printed backdoor contracts
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.7 18.12.4.1 18.12.5.1 18.12.5.2 18.12.5.4 18.12.6.2 18.12.7.1 18.12.7.2.1 18.12.7.2.2 18.12.7.2.3 18.12.7.2.4 18.12.7.2.5 18.12.7.2.6 18.12.7.2.7 1800-2023 6.21 8.20
:uvm: 2020.3.1
:files: helpers90_region/region_fixture90.svh
:incdirs: helpers90_region
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mam_region_live_descriptors_1_90.expected
*/
// Only live manager-produced descriptors are compared. No public-constructor
// prohibition or identity promise after release is inferred.
module test_mam_region_live_descriptors_1_90;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  localparam int MODE=1;
  localparam int LAYOUT=1;
  localparam string CASE_NAME="mam_region_live_descriptors_1";
  `include "region_fixture90.svh"
  initial begin #5000; $fatal(1,"manager/backdoor90 watchdog"); end
endmodule
