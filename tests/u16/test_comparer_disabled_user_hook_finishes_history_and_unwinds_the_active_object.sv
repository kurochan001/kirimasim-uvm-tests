/*
:name: test_comparer_disabled_user_hook_finishes_history_and_unwinds_the_active_object
:description: comparer disabled user hook finishes history and unwinds the active object
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.3.4 16.3.3.5 16.1.3 16.1.3.2 16.1.3.3 16.1.3.4 16.1.4 5.3.13 5.7.2.8 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_disabled_user_hook_finishes_history_and_unwinds_the_active_object.expected
*/
module test_comparer_disabled_user_hook_finishes_history_and_unwinds_the_active_object;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  string trace="";
  class audit_policy extends uvm_comparer;
    uvm_object lhs,rhs;
    bit done_before_pop=0;
    virtual function uvm_object pop_active_object();
      bit result;
      done_before_pop=object_compared(lhs,rhs,UVM_DEEP,result)==uvm_policy::FINISHED;
      trace={trace,"X"}; return super.pop_active_object();
    endfunction
  endclass
  class item extends uvm_object;
    `uvm_object_utils(item)
    uvm_comparer selected;
    uvm_object expected_rhs;
    int executes=0,users=0,payload=0;
    bit suppress=0;
    function new(string name="item"); super.new(name); endfunction
    virtual function void do_execute_op(uvm_field_op field_op);
      uvm_comparer actual;
      bit result;
      if (!$cast(actual,field_op.get_policy())) $fatal(1,"wrong operation policy");
      executes++; trace={trace,"E"};
      $display("UT: policy_execute op %s exact %0d active %0d depth %0d started %0d",
               field_op.get_op_name(),actual==selected,actual.get_active_object()==this,
               actual.get_active_object_depth(),
               selected.object_compared(this,expected_rhs,UVM_DEEP,result)==uvm_policy::STARTED);
      if (suppress) field_op.disable_user_hook();
    endfunction
    virtual function bit do_compare(uvm_object rhs,uvm_comparer comparer);
      bit result;
      users++; trace={trace,"U"};
      $display("UT: policy_user exact %0d rhs %0d active %0d started %0d unfinished %0d",
               comparer==selected,rhs==expected_rhs,comparer.get_active_object()==this,
               comparer.object_compared(this,rhs,UVM_DEEP,result)==uvm_policy::STARTED,result==0);
      return 1;
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
    result=policy.compare_object("selected",lhs,rhs);
    state=policy.object_compared(lhs,rhs,UVM_DEEP,history_value);
    $display("UT: policy_end trace %s executes %0d users %0d finished %0d consistent %0d empty %0d",
             trace,lhs.executes,lhs.users,state==uvm_policy::FINISHED,history_value==result,
             policy.get_active_object()==null && policy.get_active_object_depth()==0);
    $display("UT: finished_before_pop %0d",policy.done_before_pop);
    $finish;
  end
endmodule
