/*
:name: test_pkg_wait_operators_0_91
:description: pkg wait operators 0 observes named selections through original public-API fixtures
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.5.3 9.3.1.1.3 9.3.1.3.1 9.3.1.4.1 9.3.1.8.3 F.2.5.2 1800-2023 6.21 8.20 8.21 9.2 9.4 11.4
:uvm: 2020.3.1
:files: helpers91_wait/wait_fixture91.svh
:incdirs: helpers91_wait
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pkg_wait_operators_0_91.expected
*/
// Six typed operators are checked on a stable uninitialized IMP state against
// equal or different named thresholds. True predicates return
// immediately;false waits remain blocked until canceled. No numeric enum
// encoding,state-mask or complete live progression claim.
module test_pkg_wait_operators_0_91;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=0;
  localparam string CASE_NAME="pkg_wait_operators_0";
  `include "wait_fixture91.svh"
  initial begin #5000; $fatal(1,"typed role/event/topology91 watchdog"); end
endmodule
