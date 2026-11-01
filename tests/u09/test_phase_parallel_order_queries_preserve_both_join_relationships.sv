/*
:name: test_phase_parallel_order_queries_preserve_both_join_relationships
:description: parallel phases are unordered and share both join relationships (IEEE 1800.2-2020 Section 9.3.1.4.7)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.4.7 9.3.1.4.6 9.3.1.6.1 9.3.1.4.4 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_parallel_order_queries_preserve_both_join_relationships.expected
*/
// Inspect local phase metadata and graphs without executing phase callbacks.
// Do not interpret get_schedule return typing or the get_imp NODE/IMP wording.
module test_phase_parallel_order_queries_preserve_both_join_relationships;
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

    left.add(build_imp); a = left.find(build_imp);
    left.add(connect_imp, .with_phase(a)); left.add(end_imp);
    b = left.find(connect_imp); c = left.find(end_imp);
    if (a == null || b == null || c == null) $fatal(1, "missing phase node");
    $display("UT: parallel before %0d %0d after %0d %0d", a.is_before(b), b.is_before(a),
    a.is_after(b), b.is_after(a));
    $display("UT: join before %0d %0d after %0d %0d", a.is_before(c), b.is_before(c),
    c.is_after(a), c.is_after(b));
    $finish;
  end

endmodule
