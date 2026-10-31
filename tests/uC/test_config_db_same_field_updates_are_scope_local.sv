/*
:name: test_config_db_same_field_updates_are_scope_local
:description: updating one scope does not alter the same field at a different scope (IEEE 1800.2-2020 Section C.4.2.2.1)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.1 C.4.2.2.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_db_same_field_updates_are_scope_local.expected
*/
// Two literal scopes use the same field name. Updating one setting
// replaces only that scope value, leaving the second scope independently set.

module test_config_db_same_field_updates_are_scope_local;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    int first_value;
    int second_value;
    bit first_found;
    bit second_found;
    uvm_config_db#(int)::set(null, "env.first", "limit", 7);
    uvm_config_db#(int)::set(null, "env.second", "limit", 11);
    uvm_config_db#(int)::set(null, "env.first", "limit", 19);
    first_found = uvm_config_db#(int)::get(null, "env.first", "limit", first_value);
    second_found = uvm_config_db#(int)::get(null, "env.second", "limit", second_value);
    $display("UT: first found %0d value %0d", first_found, first_value);
    $display("UT: second found %0d value %0d", second_found, second_value);
    $finish;
  end
endmodule
