/*
:name: test_copier_field_automation_distinguishes_deep_shallow_and_default_child_ownership
:description: copier field automation distinguishes deep shallow and default child ownership
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.6.3 16.6.4.1 B.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_copier_field_automation_distinguishes_deep_shallow_and_default_child_ownership.expected
*/
// What it checks:
// 1. Deep copy recursively copies object fields instead of sharing the child
//    reference.
// 2. SHALLOW copies the root field and aliases the original child handle.
// 3. UVM_DEFAULT_POLICY copy creates an independent selected child as DEEP
//    does.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.6.3 (UVM-COPIER-DEEP-CHILD) gives rule 1 above. Setup:
//    Copy one nested child with deep policy and mutate the copied child.
//    Expected: Child handles differ, initial payload is 55 and the source
//    child retains its value.
// 2. 1800.2-2020 16.6.3 (UVM-POLICY-AUDIT-COPIER-SHALLOW-CHILD-ALIAS) gives
//    rule 2 above. Setup: Use the selected original fixtures, explicit
//    arguments and stage observations in the linked anchors; each fresh policy
//    and peer is independently constructed. Expected: SHALLOW copies the root
//    field and aliases the original child handle.
// 3. 1800.2-2020 16.6.3 (UVM-POLICY-AUDIT-COPIER-DEFAULT-AS-DEEP) gives rule 3
//    above. Setup: Use the selected original fixtures, explicit arguments and
//    stage observations in the linked anchors; each fresh policy and peer is
//    independently constructed. Expected: UVM_DEFAULT_POLICY copy creates an
//    independent selected child as DEEP does.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_copier_field_automation_distinguishes_deep_shallow_and_default_child_ownership;
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
    automatic uvm_recursion_policy_enum modes[3]='{UVM_DEEP,UVM_SHALLOW,UVM_DEFAULT_POLICY};
    foreach (modes[i]) begin
      automatic uvm_copier copier=new();
      automatic box source=new("source");
      automatic box target=new("target");
      source.child=new("child"); target.payload=-1;
      copier.set_recursion_policy(modes[i]); copier.copy_object(target,source);
      if (target.child==null) $fatal(1,"child not copied");
      $display("UT: nested_copy %0d field %0d alias %0d value %0d empty %0d",i,target.payload==7,
               target.child==source.child,target.child.payload==17,
               copier.get_active_object_depth()==0);
      target.child.payload=99;
      $display("UT: nested_copy_source %0d payload %0d",i,source.child.payload);
    end
    $finish;
  end
endmodule
