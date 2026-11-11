/*
:name: test_callback_named_lifecycle_1_0_102
:description: Named callback registration, disabled deletion and re-registration preserve per-object macro dispatch and reference arguments
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.4 B.4.1 B.4.3 B.4.4 10.7.1.1 10.7.1.2.1 10.7.1.2.2 10.7.1.2.3 10.7.2.1 10.7.2.2.1 10.7.2.2.2 10.7.2.3.1 10.7.2.3.2 10.7.2.3.4 13.1.2.1 13.1.3.2 F.7.4.1 F.3.3.1 1.4 1800-2023 6.21 8.13 8.16 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers102_named/named102.svh
:expected_exit: 0
:expected_stdout: @test_callback_named_lifecycle_1_0_102.expected
*/
// What it checks:
// 1. A disabled callback is omitted from dispatch until enabled again.
// 2. Name-based callback addition searches matching existing components from
//    the supplied root.
// 3. Name-based callback deletion removes matching registrations within its
//    search root.
// 4. The callback macro family supports registration and execution of callback
//    methods associated with the selected object context.
// 5. Named callback addition applies the specified append/prepend placement
//    independently to each matching existing component queue.
// 6. The external-object macro invokes METHOD with its supplied arguments and
//    preserves ordered reference updates for that selected context.
//
// Variant: Input 0 creates the named nodes in forward order and adds and
// deletes callbacks by name on the first branch; input 1 creates them in
// reverse order and uses the second branch. The number before them selects the
// lifecycle scenario.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.7.1.2.2 (UVM-CALLBACK-MODE-EXECUTION-GATE) gives rule 1
//    above. Setup: Disable one registered entry, dispatch, enable it and
//    dispatch again. Expected: The disabled entry is skipped initially and
//    invoked after enabling, with the other entry unaffected.
// 2. 1800.2-2020 10.7.2.3.2 (UVM-CALLBACK-ADD-BY-NAME) gives rule 2 above.
//    Setup: Use an exact full path and a glob that also matches a component
//    outside the search root. Expected: Only the matching components within
//    the search root receive the callback.
// 3. 1800.2-2020 10.7.2.3.4 (UVM-CALLBACK-DELETE-BY-NAME) gives rule 3 above.
//    Setup: Register the same callback on inside/outside leaves and delete by
//    exact path or glob. Expected: Matched inside entries stop executing while
//    outside/nonmatching registrations remain.
// 4. 1800.2-2020 B.4 (UVM-CALLBACK-OVERVIEW-REGISTERED-METHOD-EXECUTION-102)
//    gives rule 4 above. Setup: Use a valid object/callback pair registered by
//    the documented macro and uvm_callback-derived methods under10.7.1; modify
//    named registrations and explicit enabled state between completed implicit
//    or external-object invocations. Keep the overview ancestry interpretation
//    separate. Expected: Each invocation reaches the enabled callbacks
//    currently associated with its selected object, preserving the original
//    object/token, ordered transformations and independent peer memberships.
// 5. 1800.2-2020 10.7.2.3.2 (UVM-CALLBACK-NAMED-PLACEMENT-AND-READDITION-102)
//    gives rule 5 above. Setup: Start with distinct A/Z registrations on four
//    existing targets; add shared S by exact full name or glob under an
//    explicit whole-tree or branch root, then remove and re-add it between
//    completed calls. Exercise omitted APPEND, explicit APPEND and PREPEND.
//    Expected: Matching targets place S after or before their existing A/Z
//    callbacks as selected; a case-mismatched sibling and outside-root peer
//    retain their own registrations. Re-addition affects the next completed
//    dispatch and repeats without stale order.
// 6. 1800.2-2020 B.4.4 (UVM-CALLBACK-EXPLICIT-METHOD-REFERENCE-PIPELINE-102)
//    gives rule 6 above. Setup: A module function receives the actual external
//    target and invokes its macro with an object handle, token and mutable
//    value/trace references. Named registration, disabled deletion, re-enable
//    and re-addition change applicable membership only between completed
//    calls. Expected: Every reached hook receives the original selected
//    object/token, each arithmetic result flows to the next hook and caller,
//    and disabled or deleted entries contribute no transformation while
//    unrelated memberships remain independent.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_callback_named_lifecycle_1_0_102;
  import uvm_pkg::*;
  localparam int SCENARIO102=1,VARIANT102=0;
  `include "named102.svh"
endmodule
