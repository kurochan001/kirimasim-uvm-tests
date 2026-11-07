/*
:name: test_mam_reconfigure_expand_reserve_115
:description: memory-manager reconfiguration that widens the address space governs later reservations (IEEE 1800.2-2020 Section 18.12.4.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.4.2 18.12.5.1 18.12.5.3 18.12.4.1 18.12.6.2 18.12.7.2.1 18.12.7.2.2 18.12.7.2.3 18.12.9.2.1 18.12.9.2.2 18.12.9.2.3 18.12.9.2.4 18.12.9.2.5 1800-2023 6.21 8.20 18.5 18.6.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mam_reconfigure_expand_reserve_115.expected
:files: helpers115_mam_reconfigure/reconfigure115.svh
*/
// Reconfiguring the manager from 8..23 to 4..27 changes the managed address
// space. Later reservations at both new edges succeed with exact geometry, and
// the four locations just outside each new bound are rejected; locations 4..7
// and 24..27 are probed before the change as a control and released. The held
// region 12..15 stays allocated.
module test_mam_reconfigure_expand_reserve_115;
  import uvm_pkg::*;
  localparam bit EXPAND115=1;
  localparam bit REQUEST115=0;
  `include "reconfigure115.svh"
  initial begin exercise115(); $finish; end
endmodule
