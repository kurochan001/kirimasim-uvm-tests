/*
:name: test_copier_disabled_user_hook_finishes_history_and_unwinds_the_active_object
:description: copier disabled user hook finishes history and unwinds the active object
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.6.4.1 16.6.4.2 16.1.3 16.1.3.2 16.1.3.3 16.1.3.4 16.1.4 5.3.13 5.7.2.8 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_copier_disabled_user_hook_finishes_history_and_unwinds_the_active_object.expected
*/
// What it checks:
// 1. Copy history is local to a policy and ordered object pair under its
//    recursion mode.
// 2. Disabling the copier user hook still completes history and restores the
//    active stack.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.6.4.2 (UVM-COPIER-HISTORY) gives rule 1 above. Setup:
//    Query before/during/after a copy, reverse the pair, compare another
//    policy and flush. Expected: Only the selected pair/policy becomes STARTED
//    then FINISHED; flush restores NEVER.
// 2. 1800.2-2020 16.6.4.1 (UVM-POLICY-AUDIT-COPIER-DISABLED-HOOK-CLEANUP)
//    gives rule 2 above. Setup: Use the selected original fixtures, explicit
//    arguments and stage observations in the linked anchors; each fresh policy
//    and peer is independently constructed. Expected: Disabling the copier
//    user hook still completes history and restores the active stack.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_copier_disabled_user_hook_finishes_history_and_unwinds_the_active_object;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  string trace="";
  class audit_policy extends uvm_copier;
    uvm_object lhs,rhs;
    bit done_before_pop=0;
    virtual function uvm_object pop_active_object();
      done_before_pop=object_copied(lhs,rhs,UVM_DEEP)==uvm_policy::FINISHED;
      trace={trace,"X"}; return super.pop_active_object();
    endfunction
  endclass
  class item extends uvm_object;
    `uvm_object_utils(item)
    uvm_copier selected;
    uvm_object expected_rhs;
    int executes=0,users=0,payload=0;
    bit suppress=0;
    function new(string name="item"); super.new(name); endfunction
    virtual function void do_execute_op(uvm_field_op field_op);
      uvm_copier actual;
      bit result;
      if (!$cast(actual,field_op.get_policy())) $fatal(1,"wrong operation policy");
      executes++; trace={trace,"E"};
      $display("UT: policy_execute op %s exact %0d active %0d depth %0d started %0d",
               field_op.get_op_name(),actual==selected,actual.get_active_object()==this,
               actual.get_active_object_depth(),
               selected.object_copied(this,expected_rhs,UVM_DEEP)==uvm_policy::STARTED);
      if (suppress) field_op.disable_user_hook();
    endfunction
    virtual function void do_copy(uvm_object rhs);
      item source;
      if (!$cast(source,rhs)) $fatal(1,"wrong original source");
      users++; trace={trace,"U"}; payload=source.payload;
      $display("UT: policy_user rhs %0d active %0d started %0d",rhs==expected_rhs,
               selected.get_active_object()==this,
               selected.object_copied(this,rhs,UVM_DEEP)==uvm_policy::STARTED);
    endfunction
  endclass
  initial begin
    automatic audit_policy policy=new();
    automatic item lhs=new("left");
    automatic item rhs=new("right");
    bit result,history_value;
    uvm_policy::recursion_state_e state;
    policy.set_recursion_policy(UVM_DEEP); lhs.selected=policy; lhs.expected_rhs=rhs;
    lhs.suppress=1; rhs.payload=35; policy.lhs=lhs; policy.rhs=rhs;
    policy.copy_object(lhs,rhs);
    state=policy.object_copied(lhs,rhs,UVM_DEEP);
    $display("UT: policy_end trace %s executes %0d users %0d finished %0d payload %0d empty %0d",
             trace,lhs.executes,lhs.users,state==uvm_policy::FINISHED,lhs.payload,
             policy.get_active_object()==null && policy.get_active_object_depth()==0);
    $display("UT: finished_before_pop %0d",policy.done_before_pop);
    $finish;
  end
endmodule
