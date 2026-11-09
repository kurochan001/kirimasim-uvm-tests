/*
:name: test_phase_identity_distinguishes_nodes_and_matches_their_implementation
:description: phase identity matches a node to itself and its implementation (IEEE 1800.2-2020 Section 9.3.1.4.5)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.4.5 9.3.1.6.1 9.3.1.4.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_identity_distinguishes_nodes_and_matches_their_implementation.expected
*/
// What it checks:
// A phase node identifies itself and its implementation, but not an unrelated
// implementation.
//
// How the expected output follows from the standard:
// 1800.2-2020 9.3.1.4.5 (UVM-PHASE-NODE-SELF-AND-IMPLEMENTATION-IDENTITY)
// gives the rule above. Setup: Add the build singleton to two distinct
// schedules. Expected: The nodes are distinct handles; each matches build, and
// the first does not match connect.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Inspect local phase metadata and graphs without executing phase callbacks.
// Do not interpret get_schedule return typing or the get_imp NODE/IMP wording.
module test_phase_identity_distinguishes_nodes_and_matches_their_implementation;
  import uvm_pkg::*;

  initial begin
    automatic uvm_phase left = new("left", UVM_PHASE_SCHEDULE);
    automatic uvm_phase right = new("right", UVM_PHASE_SCHEDULE);
    automatic uvm_phase build_imp = uvm_build_phase::get();
    automatic uvm_phase connect_imp = uvm_connect_phase::get();
    automatic uvm_phase end_imp = uvm_end_of_elaboration_phase::get();
    uvm_phase a;
    uvm_phase b;
    uvm_phase c;

    left.add(build_imp); right.add(build_imp);
    a = left.find(build_imp); b = right.find(build_imp);
    if (a == null || b == null) $fatal(1, "missing phase node");
    $display("UT: node self %0d implementation %0d unrelated %0d", a.is(a), a.is(build_imp),
    a.is(connect_imp));
    $display("UT: distinct nodes %0d shared implementation %0d", a != b, b.is(build_imp));
    $finish;
  end

endmodule
