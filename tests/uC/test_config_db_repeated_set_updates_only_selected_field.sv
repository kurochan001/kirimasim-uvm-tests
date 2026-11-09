/*
:name: test_config_db_repeated_set_updates_only_selected_field
:description: a repeated config set updates its field while another field retains its value (IEEE 1800.2-2020 Section C.4.2.2.1)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.1 C.4.2.2.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_db_repeated_set_updates_only_selected_field.expected
*/
// What it checks:
// Updating one configuration key replaces that setting without overwriting
// other keys.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.4.2.2.1 (UVM-CONFIG-UPDATE-KEY) gives the rule above. Setup:
// Repeat set at one context/scope/field while keeping another field or exact
// scope. Expected: The selected value changes and independent fields/scopes
// retain their values.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The most recent setting at the same context and scope wins. A distinct
// field under that scope retains its previously configured value.

module test_config_db_repeated_set_updates_only_selected_field;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    int limit_value;
    int other_value;
    bit found;
    uvm_config_db#(int)::set(null, "env.agent", "limit", 3);
    uvm_config_db#(int)::set(null, "env.agent", "other", 41);
    found = uvm_config_db#(int)::get(null, "env.agent", "limit", limit_value);
    $display("UT: before found %0d limit %0d", found, limit_value);
    uvm_config_db#(int)::set(null, "env.agent", "limit", 9);
    found = uvm_config_db#(int)::get(null, "env.agent", "limit", limit_value);
    $display("UT: after found %0d limit %0d", found, limit_value);
    found = uvm_config_db#(int)::get(null, "env.agent", "other", other_value);
    $display("UT: other found %0d value %0d", found, other_value);
    $finish;
  end
endmodule
