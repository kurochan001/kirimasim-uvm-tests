/*
:name: test_callback_static_last_empty_disabled_local_103
:description: Static callback endpoints handle empty,disabled,foreign-family and selected-context boundaries
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.7.2.4.2 10.7.2.4.1 10.7.2.4.3 10.7.2.4.4 10.7.2.3.1 10.7.2.3.3 10.7.1.1 10.7.1.2.1 10.7.1.2.2 10.7.2.2.1 10.7.2.2.2 B.4.1 1800-2023 6.21 8.13 8.16
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers103_static/static103.svh
:expected_exit: 0
:expected_stdout: @test_callback_static_last_empty_disabled_local_103.expected
*/
// What it checks:
// get_last returns null when its selected context has no enabled callback of
// the requested CB type.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.7.2.4.2 (UVM-CALLBACK-STATIC-LAST-NO-ELIGIBLE-ENTRY-103)
// gives the rule above. Setup: Query an initially empty local or typewide
// queue, then a queue with all requested-family entries disabled and a live
// unrelated family. Enable selected entries and disable them again; finally
// remove the requested-family entries while leaving the unrelated family and
// excluded instance/peer registration. Expected:
// Empty,all-disabled,disabled-again and unrelated-only stages return null.
// Independent positive stages select the exact first/last enabled
// handle,including a derived callback endpoint.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_callback_static_last_empty_disabled_local_103;
  import uvm_pkg::*;
  localparam int MODE103=1,TYPEWIDE103=0;
  `include "static103.svh"
endmodule
