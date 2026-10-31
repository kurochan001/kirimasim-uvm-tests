/*
:name: test_config_db_scope_glob_matches_descendants
:description: a simplified scope pattern selects matching component descendants (IEEE 1800.2-2020 Section C.4.2.2.1)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.1 C.4.2.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_db_scope_glob_matches_descendants.expected
*/
// Use a glob scope, supported without DPI, for two explicit children.
// An unrelated component must not see this setting.

module test_config_db_scope_glob_matches_descendants;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class context_component extends uvm_component;
    `uvm_component_utils(context_component)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass

  initial begin
    automatic context_component env = new("env", null);
    automatic context_component first = new("first", env);
    automatic context_component second = new("second", env);
    automatic context_component other = new("other", null);
    automatic int value = -1;
    bit found;
    uvm_config_db#(int)::set(null, "env.*", "credit", 14);
    found = uvm_config_db#(int)::get(first, "", "credit", value);
    $display("UT: first %0d value %0d", found, value);
    found = uvm_config_db#(int)::get(second, "", "credit", value);
    $display("UT: second %0d value %0d", found, value);
    found = uvm_config_db#(int)::get(other, "", "credit", value);
    $display("UT: unrelated %0d", found);
    $finish;
  end
endmodule
