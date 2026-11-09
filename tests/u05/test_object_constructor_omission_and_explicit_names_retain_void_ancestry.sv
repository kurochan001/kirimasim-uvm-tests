/*
:name: test_object_constructor_omission_and_explicit_names_retain_void_ancestry
:description: Object constructor omission, explicit names and original virtual type dispatch
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.2 5.3.1 5.3 5.1 5.2 5.3.4.2 5.3.4.7 5.3.5.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_constructor_omission_and_explicit_names_retain_void_ancestry.expected
*/
// What it checks:
// 1. Object construction retains an omitted empty name and explicit names.
// 2. An original object extension has uvm_void ancestry.
// 3. An original object extension provides virtual identification and creation
//    interfaces.
// 4. The selected original object and transaction building blocks retain
//    object ancestry.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 5.3.2 (UVM-BASE-AUDIT-OBJECT-CONSTRUCTOR) gives rule 1 above.
//    Setup: Use direct original subclasses, actual omitted base constructor
//    calls, explicit nonempty/empty names and static base views. Expected: The
//    direct omitted base call is unnamed; nonempty/empty explicit names are
//    retained.
// 2. 1800.2-2020 5.3.1 (UVM-BASE-AUDIT-OBJECT-ANCESTRY) gives rule 2 above.
//    Setup: Use direct original subclasses, actual omitted base constructor
//    calls, explicit nonempty/empty names and static base views. Expected:
//    Implicit object/void receivers retain the same original handle.
// 3. 1800.2-2020 5.3 (UVM-BASE-AUDIT-OBJECT-INTERFACES) gives rule 3 above.
//    Setup: Use direct original subclasses, actual omitted base constructor
//    calls, explicit nonempty/empty names and static base views. Expected: A
//    base view reaches the original type-name hook and creates a distinct
//    same-type object with the requested name.
// 4. 1800.2-2020 5.1 (UVM-BASE-AUDIT-BASE-ROLE) gives rule 4 above. Setup:
//    Construct distinct original extensions and view them through the declared
//    object/void bases. Expected: Identity is retained across the selected
//    static base receivers.
// It also supports, as a control, the setup or conditions of
// UVM-BASE-AUDIT-OBJECT-VIRTUAL.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_object_constructor_omission_and_explicit_names_retain_void_ancestry;
  import uvm_pkg::*;
  class original_object extends uvm_object;
    function new(string name=""); super.new(name); endfunction
    virtual function string get_type_name(); return "original_object61"; endfunction
    virtual function uvm_object create(string name="");
      original_object result;
      result=new(name); return result;
    endfunction
  endclass
  class omitted_object extends uvm_object;
    function new(); super.new(); endfunction
    virtual function string get_type_name(); return "omitted_object61"; endfunction
    virtual function uvm_object create(string name="");
      omitted_object result;
      result=new(); result.set_name(name); return result;
    endfunction
  endclass
  initial begin
    original_object named,empty_name;
    omitted_object omitted;
    uvm_object base,other;
    uvm_void root_view;
    uvm_object created;
    original_object created_view;
    omitted=new(); named=new("named61"); empty_name=new("");
    base=named; other=omitted; root_view=base;
    $display("UT: object_names omitted %0d explicit %0d empty %0d",
      omitted.get_name()=="",named.get_name()=="named61",empty_name.get_name()=="");
    $display("UT: object_base identity %0d distinct %0d virtual_name %0d",
      root_view==named,base!=other,base.get_type_name()=="original_object61");
    created=base.create("created61");
    $display("UT: object_create virtual_type %0d distinct %0d name %0d",
      $cast(created_view,created),created!=base,created.get_name()=="created61");
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
