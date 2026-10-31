/*
:name: test_config_db_scope_question_mark_matches_one_character
:description: a scope question mark matches exactly one character (IEEE 1800.2-2020 Section C.4.2.2.1)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.1 C.4.2.2.2 F.3.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_db_scope_question_mark_matches_one_character.expected
*/
// A simplified scope pattern with one question mark matches one character.
// Keep the field name literal; configured field-name glob lookup differs
// from C.4.2.2.1 in the pinned library's default implementation.

module test_config_db_scope_question_mark_matches_one_character;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class context_component extends uvm_component;
    `uvm_component_utils(context_component)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass

  initial begin
    automatic context_component env = new("env", null);
    automatic context_component first = new("ag0", env);
    automatic context_component second = new("ag1", env);
    automatic context_component longer = new("ag12", env);
    automatic int value = -1;
    bit found;
    uvm_config_db#(int)::set(null, "env.ag?", "credit", 23);
    found = uvm_config_db#(int)::get(first, "", "credit", value);
    $display("UT: first %0d value %0d", found, value);
    found = uvm_config_db#(int)::get(second, "", "credit", value);
    $display("UT: second %0d value %0d", found, value);
    found = uvm_config_db#(int)::get(longer, "", "credit", value);
    $display("UT: two characters found %0d", found);
    $finish;
  end
endmodule
