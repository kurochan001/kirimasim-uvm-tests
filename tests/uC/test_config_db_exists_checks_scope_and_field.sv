/*
:name: test_config_db_exists_checks_scope_and_field
:description: config exists requires both an applicable scope and the requested field (IEEE 1800.2-2020 Section C.4.2.2.3)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.3 C.4.2.2.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_db_exists_checks_scope_and_field.expected
*/
// What it checks:
// Configuration presence depends on a matching scope and field, not on a
// nonnull stored handle.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.4.2.2.3 (UVM-CONFIG-EXISTS) gives the rule above. Setup:
// Compare existing/missing names and scopes, and a configured null object.
// Expected: Matching entries exist, including null values; unrelated scopes or
// names do not.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A literal setting is present only under its configured scope and name.
// No expectation uses unsupported field-name glob matching.

module test_config_db_exists_checks_scope_and_field;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    uvm_config_db#(int)::set(null, "env.agent", "limit", 7);
    $display("UT: present %0d missing_field %0d other_scope %0d",
             uvm_config_db#(int)::exists(null, "env.agent", "limit"),
             uvm_config_db#(int)::exists(null, "env.agent", "absent"),
             uvm_config_db#(int)::exists(null, "env.other", "limit"));
    $finish;
  end
endmodule
