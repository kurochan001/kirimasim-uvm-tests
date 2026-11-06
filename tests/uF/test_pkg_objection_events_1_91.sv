/*
:name: test_pkg_objection_events_1_91
:description: pkg objection events 1 observes named selections through original public-API fixtures
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.6 10.5.1.1 10.5.1.3.3 10.5.1.3.4 10.5.1.3.7 10.5.1.4.1 10.5.1.4.2 10.5.1.4.3 10.5.1.5.2 10.5.1.5.4 1800-2023 6.21 8.20 8.21 9.2 9.4 11.4
:uvm: 2020.3.1
:files: helpers91_objection/objection_fixture91.svh
:incdirs: helpers91_objection
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pkg_objection_events_1_91.expected
*/
// Typed raised,dropped and all-dropped waiters observe the selected source
// with a partial drop and delayed original completion callback. Drain is
// explicitly zero;no cross-scope delay-unit conversion is assumed.
module test_pkg_objection_events_1_91;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=1;
  localparam string CASE_NAME="pkg_objection_events_1";
  `include "objection_fixture91.svh"
  initial begin #5000; $fatal(1,"typed role/event/topology91 watchdog"); end
endmodule
