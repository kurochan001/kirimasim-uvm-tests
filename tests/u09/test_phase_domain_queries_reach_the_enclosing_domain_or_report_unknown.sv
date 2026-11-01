/*
:name: test_phase_domain_queries_reach_the_enclosing_domain_or_report_unknown
:description: nested phase domain queries reach the enclosing domain (IEEE 1800.2-2020 Section 9.3.1.6.6)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.6.6 9.3.1.6.8 9.3.1.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_domain_queries_reach_the_enclosing_domain_or_report_unknown.expected
*/
// Inspect local phase metadata and graphs without executing phase callbacks.
// Do not interpret get_schedule return typing or the get_imp NODE/IMP wording.
module test_phase_domain_queries_reach_the_enclosing_domain_or_report_unknown;
  import uvm_pkg::*;

  initial begin
    automatic uvm_domain domain = new("alpha");
    automatic uvm_phase outer = new("outer", UVM_PHASE_SCHEDULE, domain);
    automatic uvm_phase inner = new("inner", UVM_PHASE_SCHEDULE, outer);
    automatic uvm_phase leaf = new("leaf", UVM_PHASE_NODE, inner);
    automatic uvm_phase orphan = new("orphan", UVM_PHASE_NODE);

    $display("UT: enclosing outer %0d inner %0d leaf %0d", outer.get_domain() == domain,
    inner.get_domain() == domain, leaf.get_domain() == domain);
    $display("UT: names outer %0d leaf %0d orphan %0d null %0d",
    outer.get_domain_name() == "alpha", leaf.get_domain_name() == "alpha",
    orphan.get_domain_name() == "unknown", orphan.get_domain() == null);
    $finish;
  end

endmodule
