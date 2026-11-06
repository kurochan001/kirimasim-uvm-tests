/*
:name: test_root_topology_policy_0_91
:description: root topology policy 0 observes named selections through original public-API fixtures
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.7.4.2 F.4.1 F.4.1.4.12 F.4.1.4.13 F.7.2.2 13.1.2.2 13.1.2.3 13.1.3.1 5.3.6.3 16.2.3.1 16.2.4.1 16.2.4.2 16.2.5.9 16.2.5.10 1800-2023 6.21 8.20 8.21 9.2 9.4 11.4
:uvm: 2020.3.1
:files: helpers91_topology/topology_fixture91.svh
:incdirs: helpers91_topology
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_root_topology_policy_0_91.expected
*/
// Original do_print hooks record visited user components and printer identity.
// Explicit,omitted and null calls use two policy selections. No exact
// formatted text,sibling order or callback invocation count is imposed.
module test_root_topology_policy_0_91;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=0;
  localparam string CASE_NAME="root_topology_policy_0";
  `include "topology_fixture91.svh"
  initial begin #5000; $fatal(1,"typed role/event/topology91 watchdog"); end
endmodule
