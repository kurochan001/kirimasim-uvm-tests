/*
:name: test_event_pool_initial_membership_contains_begin_accept_and_end_without_lazy_get
:description: event pool initial membership contains begin accept and end without lazy get (IEEE 1800.2-2020 Section 10.4.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.4.1 10.4.1.2.1 11.2.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_pool_initial_membership_contains_begin_accept_and_end_without_lazy_get.expected
*/
// What it checks:
// A new event pool contains the three predefined begin, accept and end
// entries.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.4.1 (UVM-SYNC-REVIEW-EVENT-POOL-INITIAL-MEMBERS) gives the
// rule above. Setup: Inspect two newly constructed pools with exists before
// any get can create an entry. Expected: All three named keys already exist in
// both pools.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Check initial named membership before any get that could lazily create it.
// The standard names three default events; this asserts neither an exact total
// size nor default object identity, global membership or event state.
module test_event_pool_initial_membership_contains_begin_accept_and_end_without_lazy_get;
  import uvm_pkg::*;
  initial begin
    automatic uvm_event_pool first = new("first");
    automatic uvm_event_pool second = new("second");
    $display("UT: event_pool_defaults first %0d/%0d/%0d second %0d/%0d/%0d",
             first.exists("begin"),first.exists("accept"),first.exists("end"),
             second.exists("begin"),second.exists("accept"),second.exists("end"));
    $finish;
  end
endmodule
