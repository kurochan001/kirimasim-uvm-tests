/*
:name: test_pkg_port_roles_0_91
:description: pkg port roles 0 observes named selections through original public-API fixtures
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.3 5.5.1 5.5.2.1 5.5.2.9 5.5.2.10 5.5.2.11 5.5.2.12 12.2.10.1.1 12.2.10.1.3 12.2.10.1.4 12.2.10.2.1 12.2.10.2.2 12.2.10.3.1 1800-2023 6.21 8.20 8.21 9.2 9.4 11.4
:uvm: 2020.3.1
:files: helpers91_ports/port_fixture91.svh
:incdirs: helpers91_ports
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pkg_port_roles_0_91.expected
*/
// Typed constructor selections and original analysis forwarding inspect named
// roles. Dummy query bodies only make the constructor probe concrete;actual
// traffic uses standard analysis classes. No enum numeric encoding or generic
// type-name contract is inferred.
module test_pkg_port_roles_0_91;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=0;
  localparam string CASE_NAME="pkg_port_roles_0";
  `include "port_fixture91.svh"
  initial begin #5000; $fatal(1,"typed role/event/topology91 watchdog"); end
endmodule
