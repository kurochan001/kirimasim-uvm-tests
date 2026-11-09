/*
:name: test_phase_full_name_includes_domain_and_nested_schedules
:description: phase full names include the enclosing domain and nested schedules (IEEE 1800.2-2020 Section 9.3.1.6.3)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.6.3 9.3.1.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_full_name_includes_domain_and_nested_schedules.expected
*/
// What it checks:
// Phase full names include their domain-to-node hierarchy while singleton
// implementations have no hierarchy.
//
// How the expected output follows from the standard:
// 1800.2-2020 9.3.1.6.3 (UVM-PHASE-DOMAIN-TO-NODE-FULL-NAME) gives the rule
// above. Setup: Use alpha.outer.inner.leaf and the build singleton. Expected:
// Each nested name includes its enclosing path; build remains build with a
// null parent.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Inspect local phase metadata and graphs without executing phase callbacks.
// Do not interpret get_schedule return typing or the get_imp NODE/IMP wording.
module test_phase_full_name_includes_domain_and_nested_schedules;
  import uvm_pkg::*;

  initial begin
    automatic uvm_domain domain = new("alpha");
    automatic uvm_phase outer = new("outer", UVM_PHASE_SCHEDULE, domain);
    automatic uvm_phase inner = new("inner", UVM_PHASE_SCHEDULE, outer);
    automatic uvm_phase leaf = new("leaf", UVM_PHASE_NODE, inner);
    automatic uvm_phase orphan = new("orphan", UVM_PHASE_NODE);

    automatic uvm_phase implementation = uvm_build_phase::get();
    $display("UT: full outer %s inner %s leaf %s", outer.get_full_name(), inner.get_full_name(),
    leaf.get_full_name());
    $display("UT: singleton name %s parent %0d", implementation.get_full_name(),
    implementation.get_parent() == null);
    $finish;
  end

endmodule
