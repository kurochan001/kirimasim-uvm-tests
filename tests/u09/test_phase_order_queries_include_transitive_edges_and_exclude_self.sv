/*
:name: test_phase_order_queries_include_transitive_edges_and_exclude_self
:description: phase order queries include transitive edges and exclude self (IEEE 1800.2-2020 Section 9.3.1.4.6)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.4.6 9.3.1.4.7 9.3.1.6.1 9.3.1.4.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_order_queries_include_transitive_edges_and_exclude_self.expected
*/
// Inspect local phase metadata and graphs without executing phase callbacks.
// Do not interpret get_schedule return typing or the get_imp NODE/IMP wording.
module test_phase_order_queries_include_transitive_edges_and_exclude_self;
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

    left.add(build_imp); left.add(connect_imp); left.add(end_imp);
    a = left.find(build_imp); b = left.find(connect_imp); c = left.find(end_imp);
    if (a == null || b == null || c == null) $fatal(1, "missing phase node");
    $display("UT: before adjacent %0d transitive %0d reverse %0d self %0d", a.is_before(b),
    a.is_before(c), c.is_before(a), b.is_before(b));
    $display("UT: after adjacent %0d transitive %0d reverse %0d self %0d", c.is_after(b),
    c.is_after(a), a.is_after(c), b.is_after(b));
    $finish;
  end

endmodule
