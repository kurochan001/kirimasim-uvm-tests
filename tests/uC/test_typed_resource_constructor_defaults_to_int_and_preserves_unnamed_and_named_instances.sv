/*
:name: test_typed_resource_constructor_defaults_to_int_and_preserves_unnamed_and_named_instances
:description: The concrete parameterized resource defaults to int and retains constructor prose defaults
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.5.1 C.2.5.2 C.2.5.4.1 C.2.5.4.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_typed_resource_constructor_defaults_to_int_and_preserves_unnamed_and_named_instances.expected
*/
// What it checks:
// 1. The concrete typed resource defaults T to int and extends the resource
//    base.
// 2. Typed resource construction retains explicit names and the prose unnamed
//    default.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 C.2.5.1 (UVM-RESOURCE-AUDIT-CONCRETE-DEFAULT-TYPE) gives rule
//    1 above. Setup: Default and explicit-int resources use bidirectional
//    static receiver assignments and distinct stored integers. Expected:
//    Default/explicit views share the same handle and preserve the selected
//    negative/positive integers.
// 2. 1800.2-2020 C.2.5.2 (UVM-RESOURCE-AUDIT-TYPED-CONSTRUCTOR-NAMES) gives
//    rule 2 above. Setup: One default-int resource omits the name and an
//    explicit-int peer supplies named58. Expected: Omitted name is empty and
//    the named resource retains named58.
// It also supports, as a control, the setup or conditions of
// UVM-RESOURCE-AUDIT-VIRTUAL-BASE, UVM-RESOURCE-AUDIT-READ-TYPE-SAFETY.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Omitted naming follows the constructor prose despite its printed argument.
module test_typed_resource_constructor_defaults_to_int_and_preserves_unnamed_and_named_instances;
  import uvm_pkg::*;
  initial begin
    automatic uvm_resource#() omitted=new();
    automatic uvm_resource#(int) named=new("named58");
    uvm_resource#(int) exact;
    uvm_resource#() alias_view;
    exact=omitted; alias_view=exact; exact=alias_view;
    omitted.write(-58); named.write(58);
    $display("UT: typed_constructor unnamed %0d named %0d exact_default_type %0d values %0d",
      omitted.get_name()=="",named.get_name()=="named58",exact==omitted,
      omitted.read()==-58 && named.read()==58);
    $finish;
  end
endmodule
