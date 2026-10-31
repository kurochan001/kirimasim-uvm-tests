/*
:name: test_config_db_exists_spell_check_preserves_result
:description: spell checking does not change whether a config setting exists (IEEE 1800.2-2020 Section C.4.2.2.3)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.3 C.4.2.2.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_db_exists_spell_check_preserves_result.expected
*/
// The optional spell check controls diagnostics. Existing and missing
// fields return the same presence result with the option enabled or disabled.

module test_config_db_exists_spell_check_preserves_result;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    uvm_config_db#(int)::set(null, "env.agent", "limit", 7);
    $display("UT: present plain %0d checked %0d",
             uvm_config_db#(int)::exists(null, "env.agent", "limit", 0),
             uvm_config_db#(int)::exists(null, "env.agent", "limit", 1));
    $display("UT: absent plain %0d checked %0d",
             uvm_config_db#(int)::exists(null, "env.agent", "limti", 0),
             uvm_config_db#(int)::exists(null, "env.agent", "limti", 1));
    $finish;
  end
endmodule
