/*
:name: test_mam_cfg_rand_locality_89
:description: locality changes from an opposite value through a constrained randomize call
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.9.2.5 18.12.2.1 18.12.2.2 18.12.9.2.1 18.12.9.2.2 18.12.9.2.3 1800-2023 6.21 18.5 18.7
:uvm: 2020.3.1
:files: helpers89_cfg_random/configuration_rand_fixture89.svh
:incdirs: helpers89_cfg_random
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mam_cfg_rand_locality_89.expected
*/
module test_mam_cfg_rand_locality_89;
  import uvm_pkg::*;
  localparam int MODE=1;
  localparam string CASE_NAME="mam_cfg_rand_locality";
  `include "configuration_rand_fixture89.svh"
  initial begin #5000; $fatal(1,"configuration random89 watchdog"); end
endmodule
