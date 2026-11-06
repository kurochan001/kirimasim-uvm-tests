/*
:name: test_pkg_phase_kinds_prescoped_1_91
:description: pkg phase kinds 1 observes named selections through original public-API fixtures
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.5.1 9.3.1.3.1 9.3.1.3.2 9.3.1.4.4 9.3.1.5.1 9.3.1.6.1 9.3.1.6.2 9.3.1.6.6 9.4.1 9.4.2.1 9.6.2.1 9.6.2.2 9.6.2.3 9.7.2.1 9.7.2.2 9.7.2.3 13.1.4.4.2 1800-2023 6.21 8.20 8.21 9.2 9.4 11.4
:uvm: 2020.3.1
:files: helpers91_phase_prescoped/phase_fixture91.svh
:incdirs: helpers91_phase_prescoped
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pkg_phase_kinds_prescoped_1_91.expected
*/
// Capture unambiguous per-schedule NODE handles before binding both schedules
// of the component domain. Only ancestor ordering is checked. get_imp
// wording,automatic scheduling and domain parallel execution remain open.
module test_pkg_phase_kinds_prescoped_1_91;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=1;
  localparam string CASE_NAME="pkg_phase_kinds_prescoped_1";
  `include "phase_fixture91.svh"
  initial begin #5000; $fatal(1,"typed role/event/topology91 watchdog"); end
endmodule
