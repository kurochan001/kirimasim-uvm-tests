/*
:name: test_event_1_94
:description: Bare event field copying shares the selected event and a negative copy flag preserves an independent event
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.2.1.6 B.2.2 5.3.8.1 F.2.1.8 F.2.1.9 1800-2023 6.21 8.20 8.21 13.5.2 15.5.5 15.5.5.1 15.5.5.3
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers94_event/event_fixture94.svh
:expected_exit: 0
:expected_stdout: @test_event_1_94.expected
*/
// What it checks:
// Under the bare SystemVerilog event reading, the event field macro copies an
// enabled synchronization handle while respecting a selected negative copy
// flag.
//
// Variant: Input 1 also copies a peer event into the target before the checks
// and triggers the original event before the waiters are checked; input 0 does
// neither.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.2.2.1.6 (UVM-BARE-EVENT-MACRO-COPY-NOTIFICATION-94) gives the
// rule above. Setup: Use original objects with default-created event
// properties, COPY and COPY|NOCOPY flags. Arm original target waiters before
// copying and new waiters after copying, with positive-time separation; one
// input replaces the enabled source a second time. Expected: The enabled event
// aliases the selected source and wakes its new waiter, while the pre-copy
// enabled waiter stays quiet. The excluded target retains its original
// notification queue independently of the source, with one notification each.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_event_1_94;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT=1;
  `include "event_fixture94.svh"
endmodule
