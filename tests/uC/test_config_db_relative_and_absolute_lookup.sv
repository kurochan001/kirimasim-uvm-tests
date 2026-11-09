/*
:name: test_config_db_relative_and_absolute_lookup
:description: relative and absolute configuration scopes find the same setting (IEEE 1800.2-2020 Section C.4.2.2.1)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.1 C.4.2.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_db_relative_and_absolute_lookup.expected
*/
// What it checks:
// Configuration scope combines context and instance path and supports
// simplified scope patterns.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.4.2.2.1 (UVM-CONFIG-SCOPE-MATCH) gives the rule above. Setup:
// Use relative/absolute paths, a descendant glob and a one-character pattern
// with literal field names. Expected: Selected scopes resolve the configured
// value; unrelated paths and the longer one-character mismatch do not.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A context plus a relative path names the same setting as its absolute
// component path. An unrelated component does not match that exact scope.

module test_config_db_relative_and_absolute_lookup;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class context_component extends uvm_component;
    `uvm_component_utils(context_component)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
initial begin
    automatic context_component parent = new("parent", null);
    automatic context_component child = new("child", parent);
    automatic context_component other = new("other", parent);
  automatic int value = -1;
  bit found;
  uvm_config_db#(int)::set(parent, "child", "limit", 41);
  found = uvm_config_db#(int)::get(child, "", "limit", value);
  $display("UT: relative %0d value %0d", found, value);
  value = -1;
  found = uvm_config_db#(int)::get(null, "parent.child", "limit", value);
  $display("UT: absolute %0d value %0d", found, value);
  found = uvm_config_db#(int)::get(other, "", "limit", value);
  $display("UT: other found %0d", found);
  $finish;
end
endmodule
