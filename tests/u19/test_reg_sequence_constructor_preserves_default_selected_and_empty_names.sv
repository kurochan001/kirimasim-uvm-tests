/*
:name: test_reg_sequence_constructor_preserves_default_selected_and_empty_names
:description: reg sequence constructor preserves default selected and empty names (IEEE 1800.2-2020 Section 19.4.1.4.1)
:tags: u19 uvm
:type: simulation
:lrm: 1800.2-2020 19.4.1.4.1 19.4.1.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_sequence_constructor_preserves_default_selected_and_empty_names.expected
*/
// What it checks:
// The register-sequence constructor provides its declared optional name.
//
// How the expected output follows from the standard:
// 1800.2-2020 19.4.1.4.1 (UVM-REG-PIPELINE-SEQUENCE-CONSTRUCTOR-NAMES) gives
// the rule above. Setup: Construct omitted, selected and explicitly empty
// names. Expected: Names match the declared default, selected name and empty
// string.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Only the declared optional constructor names are observed. No default
// translation execution, factory path or unspecified field default is
// inferred.
module test_reg_sequence_constructor_preserves_default_selected_and_empty_names;
  import uvm_pkg::*;
  initial begin
    automatic uvm_reg_sequence omitted = new();
    automatic uvm_reg_sequence named = new("selected");
    automatic uvm_reg_sequence empty = new("");
    $display("UT: reg_sequence_names omitted %0d named %0d empty %0d",
             omitted.get_name() == "uvm_reg_sequence_inst", named.get_name() == "selected",
             empty.get_name() == "");
    $finish;
  end
endmodule
