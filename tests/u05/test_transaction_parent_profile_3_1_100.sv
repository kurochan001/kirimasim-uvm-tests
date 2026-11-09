/*
:name: test_transaction_parent_profile_3_1_100
:description: Current transaction begin records and links the selected parent before its hook and named event, with omitted/zero controls
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.4.2.4 5.4.2.5 5.4.2.6 5.4.2.8 5.4.2.11 5.4.2.13 5.4.2.16 7.1.3.1 7.1.4.1 7.1.5 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.5.1 7.2.7.1 7.2.7.2 7.2.7.3 7.2.7.4 7.3.1.3.1 7.3.1.3.3 7.3.2 10.2.2.3 10.7.2.2.2 16.4.5.1 16.4.5.2 16.4.7.1 16.4.7.2 16.4.7.3 16.4.7.4 16.4.7.5 16.4.7.6 16.4.7.9 16.4.7.10 16.4.7.11 1800-2023 6.16 6.16.2 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transaction_parent_profile_3_1_100.expected
:files: helpers100/transaction_parent100.svh
*/
// What it checks:
// 1. A recorded begin with a live nonzero parent handle establishes a typed
//    parent-child relation to the selected parent recorder.
// 2. Recording and any requested parent relation are ready before the begin
//    hook, which precedes the named begin event.
// 3. A new begin after end starts another recording while unrelated live
//    parent and peer recordings retain their handles.
//
// Variant: Inputs 0 and 1 swap which of two transactions is the selected one
// and which is the peer, and reverse their construction order; the profile
// number before them selects how the transactions begin.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.4.2.4 (UVM-TRANSACTION-BEGIN-PARENT-RELATION-100) gives
//    rule 1 above. Setup: Keep two parent recordings open, select each through
//    explicit handles, and begin two children and a repeated selected child
//    with reversed construction/selection. Expected: Each child has a
//    parent-child relation whose two endpoints are exactly its new recorder
//    and the selected parent recorder, without a relation to another parent.
// 2. 1800.2-2020 5.4.2.4
//    (UVM-TRANSACTION-BEGIN-RECORDING-BEFORE-HOOK-EVENT-100) gives rule 2
//    above. Setup: Observe standard protected do_begin_tr and a typed callback
//    on the transaction pool begin event for three sequential begin calls.
//    Expected: At the hook, the new recorder/handle and required relation
//    exist with the same begin time; event callbacks observe the completed
//    hook count.
// 3. 1800.2-2020 5.4.2.4 (UVM-TRANSACTION-BEGIN-REOPEN-INDEPENDENT-100) gives
//    rule 3 above. Setup: End the selected child, begin it again, and retain
//    the peer child and both parents throughout; use explicit nonzero begin
//    times in the parent-linked profiles. Expected: Each begin calls
//    open_recorder once and returns that recorder handle; explicit times agree
//    and the live peer handles remain independent.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_transaction_parent_profile_3_1_100;
  import uvm_pkg::*;
  localparam int MODE100=3,VARIANT100=1;
  `include "transaction_parent100.svh"
endmodule
