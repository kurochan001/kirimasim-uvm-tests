/*
:name: test_run_test_callback_derived_constructors_preserve_default_and_explicit_names
:description: Legal run-test callback extensions retain inherited constructor naming and callback ancestry
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.6.2.1 F.6.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_run_test_callback_derived_constructors_preserve_default_and_explicit_names.expected
*/
// What it checks:
// Run-test callback construction preserves omitted, explicit and empty names.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.6.2.1 (UVM-PACKAGE-AUDIT-CALLBACK-CONSTRUCTOR) gives the rule
// above. Setup: Original legal concrete extensions call only super.new, with
// the default omitted in one extension. Expected: The default is
// uvm_run_test_callback, explicit/empty names are preserved and the instance
// is a uvm_callback.
// It also supports, as a control, the setup or conditions of
// UVM-PACKAGE-AUDIT-CALLBACK-VIRTUAL-BASE.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_run_test_callback_derived_constructors_preserve_default_and_explicit_names;
  import uvm_pkg::*;
  class default_callback extends uvm_run_test_callback;
    function new(); super.new(); endfunction
  endclass
  class named_callback extends uvm_run_test_callback;
    function new(string name); super.new(name); endfunction
  endclass
  initial begin
    automatic default_callback omitted=new();
    automatic named_callback named=new("named57");
    automatic named_callback empty=new("");
    uvm_callback base_view;
    base_view=omitted;
    $display("UT: callback_constructor default_name %0d explicit_name %0d empty_name %0d base %0d",
      omitted.get_name()=="uvm_run_test_callback",named.get_name()=="named57",
      empty.get_name()=="",base_view==omitted);
    $finish;
  end
endmodule
