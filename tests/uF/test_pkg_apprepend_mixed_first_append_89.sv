/*
:name: test_pkg_apprepend_mixed_first_append_89
:description: pkg apprepend mixed first append observes independently derived enum effects and preserved controls
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.7 10.7.2.3.1 B.4.1 B.4.3 1800-2023 6.21 8.20 18.5
:uvm: 2020.3.1
:files: helpers89/apprepend_fixture89.svh
:incdirs: helpers89
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pkg_apprepend_mixed_first_append_89.expected
*/
module test_pkg_apprepend_mixed_first_append_89;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=0;
  localparam string CASE_NAME="pkg_apprepend_mixed_first_append";
  `include "apprepend_fixture89.svh"
  initial begin #5000; $fatal(1,"allocation or ordering89 watchdog"); end
endmodule
