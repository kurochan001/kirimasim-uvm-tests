/*
:name: test_comparer_field_automation_distinguishes_nested_recursion_and_alias_conditions
:description: comparer field automation distinguishes nested recursion and alias conditions
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.4.1 16.3.3.4 B.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_field_automation_distinguishes_nested_recursion_and_alias_conditions.expected
*/
// What it checks:
// 1. Reference comparison uses handle identity while deep comparison inspects
//    object fields.
// 2. SHALLOW compares child handles while DEEP compares selected child fields.
// 3. UVM_DEFAULT_POLICY comparison treats the selected equal distinct children
//    as DEEP.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.3.4.1 (UVM-COMPARER-RECURSION-MODE) gives rule 1 above.
//    Setup: Compare an alias and a distinct equal-valued object with
//    independent comparers. Expected: Only the alias passes reference
//    comparison; equal fields can pass deep comparison.
// 2. 1800.2-2020 16.3.4.1 (UVM-POLICY-AUDIT-COMPARER-SHALLOW-CHILD-IDENTITY)
//    gives rule 2 above. Setup: Use the selected original fixtures, explicit
//    arguments and stage observations in the linked anchors; each fresh policy
//    and peer is independently constructed. Expected: SHALLOW compares child
//    handles while DEEP compares selected child fields.
// 3. 1800.2-2020 16.3.4.1 (UVM-POLICY-AUDIT-COMPARER-DEFAULT-AS-DEEP) gives
//    rule 3 above. Setup: Use the selected original fixtures, explicit
//    arguments and stage observations in the linked anchors; each fresh policy
//    and peer is independently constructed. Expected: UVM_DEFAULT_POLICY
//    comparison treats the selected equal distinct children as DEEP.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_comparer_field_automation_distinguishes_nested_recursion_and_alias_conditions;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class leaf extends uvm_object;
    int payload=17;
    `uvm_object_utils_begin(leaf)
      `uvm_field_int(payload,UVM_DEFAULT)
    `uvm_object_utils_end
    function new(string name="leaf"); super.new(name); endfunction
  endclass
  class box extends uvm_object;
    int payload=7;
    leaf child;
    `uvm_object_utils_begin(box)
      `uvm_field_int(payload,UVM_DEFAULT)
      `uvm_field_object(child,UVM_DEFAULT)
    `uvm_object_utils_end
    function new(string name="box"); super.new(name); endfunction
  endclass
  initial begin
    automatic uvm_recursion_policy_enum modes[6]='{UVM_DEEP,UVM_SHALLOW,UVM_REFERENCE,
                                                  UVM_DEFAULT_POLICY,UVM_SHALLOW,UVM_DEEP};
    foreach (modes[i]) begin
      automatic uvm_comparer comparer=new();
      automatic box lhs=new("lhs");
      automatic box rhs=new("rhs");
      bit result;
      lhs.child=new("child"); rhs.child=new("child");
      if (i==4) lhs.child=rhs.child;
      if (i==5) rhs.child.payload=29;
      comparer.set_recursion_policy(modes[i]); result=comparer.compare_object("value",lhs,rhs);
      $display("UT: nested_compare %0d equal %0d alias %0d empty %0d",i,result,
               lhs.child==rhs.child,comparer.get_active_object_depth()==0);
    end
    $finish;
  end
endmodule
