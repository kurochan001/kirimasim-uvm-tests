/*
:name: test_phase_implementation_lookup_stays_within_each_local_schedule
:description: implementation lookup stays within each local phase schedule (IEEE 1800.2-2020 Section 9.3.1.4.4)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.4.4 9.3.1.6.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_implementation_lookup_stays_within_each_local_schedule.expected
*/
// What it checks:
// Default implementation lookup stays within the local schedule.
//
// How the expected output follows from the standard:
// 1800.2-2020 9.3.1.4.4 (UVM-PHASE-IMPLEMENTATION-LOOKUP-SCOPE) gives the rule
// above. Setup: Give the left schedule build/connect and the right schedule
// build only. Expected: Lookups return the correct local handles; missing
// implementations return null.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The pinned library returns the IMP, not its node, for a current-node
// implementation lookup. Retain the required node handle from 9.3.1.4.4.
// Inspect local phase metadata and graphs without executing phase callbacks.
// Do not interpret get_schedule return typing or the get_imp NODE/IMP wording.
module test_phase_implementation_lookup_stays_within_each_local_schedule;
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

    left.add(build_imp); left.add(connect_imp); right.add(build_imp);
    a = left.find(build_imp); b = left.find(connect_imp); c = right.find(build_imp);
    if (a == null || b == null || c == null) $fatal(1, "missing phase node");
    $display("UT: scoped left %0d right %0d distinct %0d", a.find(connect_imp) == b,
    c.find(build_imp) == c, a != c);
    $display("UT: absent right %0d left %0d", c.find(connect_imp) == null, a.find(end_imp) == null);
    $finish;
  end

endmodule
