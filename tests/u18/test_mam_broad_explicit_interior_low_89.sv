/*
:name: test_mam_broad_explicit_interior_low_89
:description: mam broad explicit interior low observes independently derived enum effects and preserved controls
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.2.2 18.12.2.1 18.12.2.2 18.12.9.2.4 18.12.9.2.5 18.12.4.1 18.12.4.2 18.12.5.1 18.12.5.2 18.12.5.3 18.12.6.2 18.12.7.2.1 18.12.7.2.2 18.12.7.2.3 18.12.7.2.4 18.12.8.1 18.12.8.2.2 1800-2023 6.21 8.20 18.5
:uvm: 2020.3.1
:files: helpers89/mam_modes_fixture89.svh
:incdirs: helpers89
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mam_broad_explicit_interior_low_89.expected
*/
module test_mam_broad_explicit_interior_low_89;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=8;
  localparam string CASE_NAME="mam_broad_explicit_interior_low";
  `include "mam_modes_fixture89.svh"
  initial begin #5000; $fatal(1,"allocation or ordering89 watchdog"); end
endmodule
