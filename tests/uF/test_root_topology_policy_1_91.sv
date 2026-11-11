/*
:name: test_root_topology_policy_1_91
:description: root topology policy 1 observes named selections through original public-API fixtures
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
:expected_stdout: @test_root_topology_policy_1_91.expected
*/
// What it checks:
// An omitted root topology printer argument uses the current default printer
// policy.
//
// Variant: Input 0 prints the topology with an explicit printer, input 1 with
// the default printer that it sets first, and input 2 with a null printer
// argument.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.7.4.2 (UVM-ROOT-TOPOLOGY-PRINTER-OMITTED-91) gives the rule
// above. Setup: Two original printers and five original components form two
// hierarchy branches. Across two calls,explicit selection opposes the default
// or omitted/null selection follows its replacement. Original do_print hooks
// record policy identity and membership;emitters only observe the selected
// sink. Restore the prior global default afterwards. Expected: Every selected
// user component is visited with the selected policy and only its emitter is
// used;the hierarchy and restored prior default remain intact.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original do_print hooks record visited user components and printer identity.
// Explicit,omitted and null calls use two policy selections. No exact
// formatted text,sibling order or callback invocation count is imposed.
module test_root_topology_policy_1_91;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=1;
  localparam string CASE_NAME="root_topology_policy_1";
  `include "topology_fixture91.svh"
  initial begin #5000; $fatal(1,"typed role/event/topology91 watchdog"); end
endmodule
