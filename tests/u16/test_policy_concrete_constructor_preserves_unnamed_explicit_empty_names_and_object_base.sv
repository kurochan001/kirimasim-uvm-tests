/*
:name: test_policy_concrete_constructor_preserves_unnamed_explicit_empty_names_and_object_base
:description: policy concrete constructor preserves unnamed explicit empty names and object base
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.1.2.1 16.1.1 16.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_concrete_constructor_preserves_unnamed_explicit_empty_names_and_object_base.expected
*/
// What it checks:
// 1. A legal concrete policy subtype retains the declared object base.
// 2. The policy constructor defaults to unnamed and preserves forwarded
//    explicit/empty names.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.1.1 (UVM-PRINTER-AUDIT-POLICY-OBJECT-BASE) gives rule 1
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The
//    corresponding default/named/empty and exact base identity observations
//    match.
// 2. 1800.2-2020 16.1.2.1 (UVM-PRINTER-AUDIT-POLICY-CONSTRUCTOR) gives rule 2
//    above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The
//    corresponding default/named/empty and exact base identity observations
//    match.
// It also supports, as a control, the setup or conditions of
// UVM-PRINTER-AUDIT-UVM-POLICY-DIRECT-CONSTRUCTION.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_policy_concrete_constructor_preserves_unnamed_explicit_empty_names_and_object_base;
  import uvm_pkg::*;
  class omitted_policy extends uvm_policy;
  endclass
  class named_policy extends uvm_policy;
    function new(string name); super.new(name); endfunction
  endclass
  initial begin
    automatic omitted_policy omitted=new();
    automatic named_policy named=new("selected");
    automatic named_policy empty=new("");
    automatic uvm_object base_view=named;
    $display("UT: policy_names default %0d named %0d empty %0d base %0d",omitted.get_name()=="",
             named.get_name()=="selected",empty.get_name()=="",base_view==named);
    $finish;
  end
endmodule
